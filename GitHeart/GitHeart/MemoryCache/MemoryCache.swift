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
/// In a case if the new value exceeds the `maxByteSize` the cache will start to remove old values to fit
/// the new one.
///
/// The class is thread safe.
///
/// Time complexity to get the value is O(n). Time complexity to set the value in a worst case is O(n),
/// in a best case is O(1).
final class MemoryCache<Key: Hashable, Value: ByteSizable> {
    private let serialQueue = DispatchQueue(label: "MemoryCache: \(UUID().uuidString)")
    private var list: [(Key, Value)] = []
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

    /// Returns value for the key or nil if doesn't exist.
    func value(forKey key: Key) -> Value? {
        return serialQueue.sync { index(forKey: key).map { list[$0].1 } }
    }

    /// Sets or resets value for the key.
    func set(value: Value?, for key: Key) {
        serialQueue.async {
            if let value = value {
                if self._totalSize + value.byteSize > self.maxByteSize {
                    // Remove old values until the new value fits in the cache.
                    repeat {
                        if self.list.isEmpty {
                            return
                        }
                        let item = self.list.removeFirst()
                        self._totalSize -= item.1.byteSize
                    } while self._totalSize + value.byteSize > self.maxByteSize
                }
                self._totalSize += value.byteSize
                self.list.append((key, value))
            } else {
                if let index = self.index(forKey: key) {
                    // Evict the value.
                    self._totalSize -= self.list[index].1.byteSize
                    self.list.remove(at: index)
                }
            }
        }
    }

    /// Clears the cache.
    func clear() {
        serialQueue.async {
            self.list.removeAll(keepingCapacity: false)
            self._totalSize = 0
        }
    }

    private func index(forKey key: Key) -> Int? {
        return list.lazy.enumerated().reversed().first(where: { $0.1.0 == key })?.offset
    }
}
