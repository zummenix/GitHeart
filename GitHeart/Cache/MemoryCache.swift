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
/// The class is thread safe.
///
/// Time complexity to get the value is O(1).
/// Time complexity to set the value is O(n) in a worst case, O(1) in a best case.
final class MemoryCache<Key: Hashable, Value: ByteSizable> {
    private let serialQueue = DispatchQueue(label: "MemoryCache: \(UUID().uuidString)")
    private var map: [Key: Value] = [:]
    private var queue: [Key] = [] // Added keys are new.
    private var _totalSize: Int = 0

    /// The total size of the cache in bytes.
    var totalSize: Int {
        return serialQueue.sync { _totalSize }
    }

    /// Maximum size of the cache in bytes.
    let maxByteSize: Int

    init(maxByteSize: Int) {
        self.maxByteSize = maxByteSize
    }

    private func evictValueIfExists(forKey key: Key) {
        if let value = map[key] {
            _totalSize -= value.byteSize
            map[key] = nil
            let i = queue.firstIndex(where: { $0 == key })! // The key should exist in the queue.
            queue.remove(at: i)
        }
    }

    private func doesExceedMaxByteSize(for addedByteSize: Int) -> Bool {
        return _totalSize + addedByteSize > maxByteSize
    }
}

extension MemoryCache: Cache {
    typealias Key = Key
    typealias Value = Value

    func value(forKey key: Key) -> Value? {
        return serialQueue.sync { map[key] }
    }

    func set(value: Value?, for key: Key) {
        serialQueue.async {
            if let value = value {
                self.evictValueIfExists(forKey: key)
                if self.doesExceedMaxByteSize(for: value.byteSize) {
                    // Remove old values until the new value fits in the cache.
                    repeat {
                        if self.queue.isEmpty {
                            return
                        }
                        let oldKey = self.queue.removeFirst()
                        let oldValue = self.map[oldKey]! // The value should exist in the map.
                        self.map[oldKey] = nil
                        self._totalSize -= oldValue.byteSize
                    } while self.doesExceedMaxByteSize(for: value.byteSize)
                }
                self._totalSize += value.byteSize
                self.queue.append(key)
                self.map[key] = value
            } else {
                self.evictValueIfExists(forKey: key)
            }
        }
    }

    func removeAll() {
        serialQueue.async {
            self.queue.removeAll(keepingCapacity: false)
            self.map.removeAll(keepingCapacity: false)
            self._totalSize = 0
        }
    }

    func freeMemory() {
        removeAll()
    }
}
