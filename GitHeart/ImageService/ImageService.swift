//
//  ImageService.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import OSLog
import UIKit

/// Responsible for requesting and providing an image by its url.
class ImageService<C: Cache> where C.Key == URL, C.Value == Data {
    private let session: URLSession
    private let cache: C

    init(session: URLSession, cache: C) {
        self.session = session
        self.cache = cache
    }
}

extension ImageService: ImageProvider {
    func imageBy(url: URL, completion: @escaping (UIImage?) -> Void) -> ImageProviderTask? {
        if let data = cache.value(forKey: url), let image = UIImage(data: data) {
            completion(image)
            return nil
        } else {
            let task = session.dataTask(with: url) { [weak self] data, _, error in
                if let error = error {
                    if (error as NSError).code == NSURLErrorCancelled {
                        return
                    }
                    DispatchQueue.main.async {
                        os_log(.error, "ImageService: failed to download image at %@. Error: %@", url.absoluteString, error.localizedDescription)
                        completion(nil)
                    }

                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self?.cache.set(value: data, for: url)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        os_log(.error, "ImageService: failed to decode image")
                        completion(nil)
                    }
                }
            }
            task.resume()
            return task
        }
    }
}

extension URLSessionTask: ImageProviderTask {}
