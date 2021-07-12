//
//  Debouncer.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 12.07.2021.
//

import Foundation

/// A type that is able to debounce a call.
protocol Debouncer: AnyObject {
    /// Schedules work to perform at later time and cancels previous work if it was in progress.
    func debounce(call: @escaping (() -> Void))
}
