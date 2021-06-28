//
//  User.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import Foundation

struct User: Codable {
    let id: Int
    let login: String
}

struct PaginatedUsers: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [User]
}
