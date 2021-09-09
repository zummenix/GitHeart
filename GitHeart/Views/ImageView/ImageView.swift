//
//  ImageView.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import UIKit

/// A image view that is able to show an image from an `imageProvider`.
class ImageView: UIImageView {
    private var task: ImageProviderTask?

    override var image: UIImage? {
        set {
            super.image = newValue
            task?.cancel()
        }
        get {
            return super.image
        }
    }

    /// Sets an image by the `url` using an `imageProvider`.
    func setImage(url: URL?, imageProvider: ImageProvider) {
        image = nil
        guard let url = url else { return }
        task = imageProvider.imageBy(url: url, completion: { [weak self] image in
            self?.image = image
        })
    }
}
