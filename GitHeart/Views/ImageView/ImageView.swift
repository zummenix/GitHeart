//
//  ImageView.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import UIKit

/// A image view that is able to show an image from an `imageProvider`.
class ImageView: UIImageView {
    private var task: Task<Void, Never>?
    private var currentURL: URL?

    /// Sets an image by the `url` using an `imageProvider`.
    func setImage(url: URL?, imageProvider: ImageProvider) {
        guard currentURL != url else { return }

        task?.cancel()
        task = nil

        image = nil
        currentURL = url

        guard let url = url else { return }

        task = Task {
            let image = await imageProvider.imageBy(url: url)
            if currentURL == url {
                self.image = image
            }
        }
    }
}
