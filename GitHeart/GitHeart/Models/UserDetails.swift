//
//  UserDetails.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import Foundation

struct UserDetails {
    let name: String
    let login: String
    let bio: String
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let followers: Int
    let following: Int
    let publicRepos: Int
    let publicGists: Int
}
