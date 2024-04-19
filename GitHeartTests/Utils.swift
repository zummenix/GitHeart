//
//  Utils.swift
//  GitHeartTests
//
//  Created by Aleksey Kuznetsov on 18.09.2021.
//

import Foundation

/// Returns an url for a resource in the test target.
func url(forResource resource: String) throws -> URL {
    let bundle = Bundle(for: Dummy.self)
    guard let url = bundle.url(forResource: resource, withExtension: nil) else {
        throw NSError(domain: "Tests", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to locate a resource: \(resource)"])
    }
    return url
}

/// Returns data for a resource in the test target.
func data(forResource resource: String) throws -> Data {
    try Data(contentsOf: url(forResource: resource))
}

private class Dummy {}
