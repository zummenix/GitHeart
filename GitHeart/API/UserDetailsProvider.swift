//
//  UserDetailsProvider.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 03.07.2021.
//

import Foundation

/// A type that provides the details of a user.
protocol UserDetailsProvider {
    /// Requests the details of a user by its `login`.
    func userDetails(login: String, completion: @escaping (Result<UserDetails, Error>) -> Void)
}
