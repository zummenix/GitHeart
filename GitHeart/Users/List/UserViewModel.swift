//
//  UserViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import Foundation

/// A view model of a user to show it in a list.
struct UserViewModel {
    let login: String
    let avatarUrl: URL?
    let imageProvider: ImageProvider
}
