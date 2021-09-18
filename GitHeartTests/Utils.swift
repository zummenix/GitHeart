//
//  Utils.swift
//  GitHeartTests
//
//  Created by Aleksey Kuznetsov on 18.09.2021.
//

import Foundation

class Dummy {}

func url(forResource resource: String) throws -> URL {
    let bundle = Bundle(for: Dummy.self)
    guard let url = bundle.url(forResource: resource, withExtension: nil) else {
        throw NSError(domain: "Tests", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to locate a resource: \(resource)"])
    }
    return url
}

func data(forResource resource: String) throws -> Data {
    let url = try url(forResource: resource)
    return try Data(contentsOf: url)
}
