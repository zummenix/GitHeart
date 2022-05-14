//
//  DispatchQueueDebouncer.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 12.07.2021.
//

import Foundation

/// Debouncer implementation based on a dispatch queue.
struct DispatchQueueDebouncer: Debouncer {
    private var workItem: DispatchWorkItem?
    private let timeInterval: DispatchTimeInterval
    private let queue: DispatchQueue

    init(timeInterval: DispatchTimeInterval, queue: DispatchQueue = .main) {
        self.timeInterval = timeInterval
        self.queue = queue
    }

    mutating func debounce(call: @escaping (() -> Void)) {
        workItem?.cancel()
        workItem = DispatchWorkItem {
            call()
        }
        queue.asyncAfter(deadline: .now() + timeInterval, execute: workItem!)
    }
}
