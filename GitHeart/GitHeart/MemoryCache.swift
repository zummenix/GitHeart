//
//  MemoryCache.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import Foundation

protocol ByteSizable {
    var byteSize: Int { get }
}

class MemoryCache<Key: Hashable, Value: ByteSizable> {
    let maxByteSize: Int
    private var list: [(Key, Value)] = []
    private(set) var totalSize: Int = 0

    init(maxByteSize: Int) {
        self.maxByteSize = maxByteSize
    }

    func value(forKey key: Key) -> Value? {
        return index(forKey: key).map { list[$0].1 }
    }

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
            evictValue(forKey: key)
        }
    }

    func clear() {
        list.removeAll(keepingCapacity: false)
        totalSize = 0
    }

    private func index(forKey key: Key) -> Int? {
        return list.lazy.enumerated().reversed().first(where: { $0.1.0 == key })?.offset
    }

    private func evictValue(forKey key: Key) {
        if let index = index(forKey: key) {
            totalSize -= list[index].1.byteSize
            list.remove(at: index)
        }
    }
}
