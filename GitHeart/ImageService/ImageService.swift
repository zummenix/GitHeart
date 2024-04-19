//
//  ImageService.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import OSLog
import UIKit

/// Responsible for requesting and providing an image by its url.
@MainActor
final class ImageService<C: Cache> where C.Key == URL, C.Value == Data {
    private let session: URLSession
    private let cache: C

    init(session: URLSession, cache: C) {
        self.session = session
        self.cache = cache
    }
}

extension ImageService: ImageProvider {
    func imageBy(url: URL) async -> UIImage? {
        if let data = cache.value(forKey: url), let image = await UIImage.from(data: data) {
            return image
        } else {
            do {
                let (data, _) = try await session.my_data(from: url)
                if let image = await UIImage.from(data: data) {
                    cache.set(value: data, for: url)
                    return image
                } else {
                    os_log(.error, "ImageService: failed to decode image")
                    return nil
                }
            } catch {
                os_log(
                    .error, "ImageService: failed to download image at %@. Error: %@",
                    url.absoluteString, error.localizedDescription
                )
                return nil
            }
        }
    }
}

private extension URLSession {
    func my_data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url)
    }
}

private extension UIImage {
    static func from(data: Data) async -> UIImage? {
        await Task.detached { UIImage(data: data) }.value
    }
}
