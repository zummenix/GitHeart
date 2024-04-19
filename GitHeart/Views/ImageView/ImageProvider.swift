//
//  ImageProvider.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 01.07.2021.
//

import UIKit

/// A type that provides an image.
@MainActor
protocol ImageProvider {
    /// Requests an image by its `url`.
    func imageBy(url: URL) async -> UIImage?
}
