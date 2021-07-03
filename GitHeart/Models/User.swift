//
//  User.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import Foundation

/// A model of a user in a list.
struct User: Codable {
    let id: Int
    let avatarUrl: URL?
    let login: String
}

/// A model with items of users.
struct PaginatedUsers: Codable {
    let items: [User]
}
