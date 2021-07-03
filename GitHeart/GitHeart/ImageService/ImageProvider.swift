//
//  ImageProvider.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 01.07.2021.
//

import UIKit

/// A type that provides an image.
protocol ImageProvider {
    /// Requests an image by its `url`.
    ///
    /// - Returns: A task that can be cancelled.
    func imageBy(url: URL, completion: @escaping (UIImage?) -> Void) -> ImageProviderTask?
}

/// A type that represents a task of a request to `ImageProvider`
protocol ImageProviderTask {
    /// Cancells the task.
    func cancel()
}
