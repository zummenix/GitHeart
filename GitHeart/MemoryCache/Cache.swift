//
//  Cache.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 15.07.2021.
//

import Foundation

/// A type that implements a generic cache.
protocol Cache {
    /// Key type to access values.
    associatedtype Key
    /// Value type stored in a cache.
    associatedtype Value

    /// Returns a value for the key or nil if it doesn't exist.
    func value(forKey key: Key) -> Value?

    /// Sets or resets a value for the key.
    func set(value: Value?, for key: Key)

    /// Clears the cache.
    func clear()
}
