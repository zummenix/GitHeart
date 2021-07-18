//
//  Cache.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 15.07.2021.
//

import Foundation

/// A type that implements a key value cache.
protocol Cache {
    /// Key type to access values.
    associatedtype Key
    /// Value type stored in a cache.
    associatedtype Value

    /// Returns a value for the key or nil if it doesn't exist.
    func value(forKey key: Key) -> Value?

    /// Sets or resets a value for the key.
    func set(value: Value?, for key: Key)

    /// Removes all values from the cache making it effectively empty.
    func removeAll()

    /// Frees unnecessary memory.
    ///
    /// Semantics of this method depends on the implementation. For example, it might call `removeAll()`
    /// to free memory or save data on disc to access it later when needed. In general, this method should
    /// free all memory resources. Call this mehtod when memory warning occurs.
    func freeMemory()
}
