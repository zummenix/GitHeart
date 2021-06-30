//
//  WebImageView.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import UIKit

class WebImageView: UIImageView {
    private var task: URLSessionTask?

    override var image: UIImage? {
        set {
            super.image = newValue
            task?.cancel()
        }
        get {
            return super.image
        }
    }

    func setImage(url: URL?, imageService: ImageService) {
        guard let url = url else {
            image = nil
            return
        }
        task?.cancel()
        task = imageService.imageBy(url: url, completion: { [weak self] image in
            self?.image = image
        })
    }
}
