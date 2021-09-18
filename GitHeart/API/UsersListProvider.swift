//
//  UsersListProvider.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 03.07.2021.
//

import Foundation

struct UsersList {
    let users: [User]
    let next: URL?
}

/// A type that provides the list of users.
protocol UsersListProvider {
    /// Requests the first page of users applying `searchTerm` if not empty.
    func users(searchTerm: String, completion: @escaping ((Result<UsersList, Error>) -> Void))

    /// Requests the next pages of users.
    func users(url: URL, completion: @escaping ((Result<UsersList, Error>) -> Void))
}
