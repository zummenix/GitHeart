//
//  ImageProvider.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 01.07.2021.
//

import UIKit

protocol ImageProvider {
    func imageBy(url: URL, completion: @escaping (UIImage?) -> Void) -> ImageProviderTask?
}

protocol ImageProviderTask {
    func cancel()
}
