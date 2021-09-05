//
//  MemoryWarningHandler.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 05.09.2021.
//

import Foundation

/// A type that can handle a memory warning to free unnecessary memory resources.
protocol MemoryWarningHandler {
    /// Frees unnecessary memory resources.
    ///
    /// Semantics of this method depends on the implementation. For example, it might save data on disc
    /// to access it later when needed. In general, this method should free all unnecessary memory resources.
    /// Call this mehtod when a memory warning occurs.
    func freeMemory()
}
