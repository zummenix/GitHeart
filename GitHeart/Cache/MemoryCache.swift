//
//  MemoryCache.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import Foundation

/// A type that provides a size in bytes.
protocol ByteSizable {
    /// Size in bytes.
    var byteSize: Int { get }
}

/// A structure to cache values by a key, stores data in memory.
///
/// Implements FIFO cache replacement policy. When by adding a new value the size exceeds the `maxByteSize`
/// the cache will start to remove old values to fit the new one.
///
/// Time complexity to get the value is O(1).
/// Time complexity to set the value is O(n) in a worst case, O(1) in a best case.
final class MemoryCache<Key: Hashable, Value: ByteSizable> {
    private var map: [Key: Value] = [:]
    private var queue: [Key] = [] // Added keys are new.
    private var size: Int = 0

    /// The total size of the cache in bytes.
    var totalSize: Int {
        size
    }

    /// Maximum size of the cache in bytes.
    let maxByteSize: Int

    init(maxByteSize: Int) {
        self.maxByteSize = maxByteSize
    }

    private func evictValueIfExists(forKey key: Key) {
        if let value = map[key] {
            size -= value.byteSize
            map[key] = nil
            let i = queue.firstIndex(where: { $0 == key })! // The key should exist in the queue.
            queue.remove(at: i)
        }
    }

    private func doesExceedMaxByteSize(for addedByteSize: Int) -> Bool {
        size + addedByteSize > maxByteSize
    }
}

extension MemoryCache: Cache {
    typealias Key = Key
    typealias Value = Value

    func value(forKey key: Key) -> Value? {
        map[key]
    }

    func set(value: Value?, for key: Key) {
        if let value {
            evictValueIfExists(forKey: key)
            if doesExceedMaxByteSize(for: value.byteSize) {
                // Remove old values until the new value fits in the cache.
                repeat {
                    if queue.isEmpty {
                        return
                    }
                    let oldKey = queue.removeFirst()
                    let oldValue = map[oldKey]! // The value should exist in the map.
                    map[oldKey] = nil
                    size -= oldValue.byteSize
                } while doesExceedMaxByteSize(for: value.byteSize)
            }
            size += value.byteSize
            queue.append(key)
            map[key] = value
        } else {
            evictValueIfExists(forKey: key)
        }
    }

    func removeAll() {
        queue.removeAll(keepingCapacity: false)
        map.removeAll(keepingCapacity: false)
        size = 0
    }
}

extension MemoryCache: MemoryWarningHandler {
    func freeMemory() {
        removeAll()
    }
}
