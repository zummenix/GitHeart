//
//  UserDetailsProvider.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 03.07.2021.
//

/// A type that provides the details of a user.
@MainActor
protocol UserDetailsProvider {
    /// Requests the details of a user by its `login`.
    func userDetails(login: String) async throws -> UserDetails
}
