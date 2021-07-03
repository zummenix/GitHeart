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
/// In case if the new value exceeds the `maxByteSize` the cache will start to remove old values to fit
/// the new one.
///
/// Time complexity to get the value is O(n). Time complexity to set the value in a worst case is O(n),
/// in a best case is O(1).
class MemoryCache<Key: Hashable, Value: ByteSizable> {
    private var list: [(Key, Value)] = []
    private(set) var totalSize: Int = 0

    /// Maximum size of the cache.
    let maxByteSize: Int

    init(maxByteSize: Int) {
        self.maxByteSize = maxByteSize
    }

    /// Returns value for the key or nil if doesn't exist.
    func value(forKey key: Key) -> Value? {
        return index(forKey: key).map { list[$0].1 }
    }

    /// Sets or resets value for the key.
    func set(value: Value?, for key: Key) {
        if let value = value {
            if totalSize + value.byteSize > maxByteSize {
                repeat {
                    if list.isEmpty {
                        return
                    }
                    let item = list.removeFirst()
                    totalSize -= item.1.byteSize
                } while totalSize + value.byteSize > maxByteSize
            }
            totalSize += value.byteSize
            list.append((key, value))
        } else {
            if let index = index(forKey: key) {
                // Evict the value.
                totalSize -= list[index].1.byteSize
                list.remove(at: index)
            }
        }
    }

    /// Clears the cache.
    func clear() {
        list.removeAll(keepingCapacity: false)
        totalSize = 0
    }

    private func index(forKey key: Key) -> Int? {
        return list.lazy.enumerated().reversed().first(where: { $0.1.0 == key })?.offset
    }
}
