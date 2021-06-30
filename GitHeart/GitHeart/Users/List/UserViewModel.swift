//
//  UserViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import Foundation

struct UserViewModel {
    let login: String
    let avatarUrl: URL?
    let imageService: ImageService
}
