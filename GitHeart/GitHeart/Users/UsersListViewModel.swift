//
//  UsersListViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import Foundation

class UsersListViewModel {
    private var users: [User] = []

    init() {
        users = [User(name: "Aleksey Kuznetsov", login: "zummenix")]
    }

    func numberOfUsers() -> Int {
        return users.count
    }

    func userViewModel(at index: Int) -> UserViewModel {
        let user = users[index]
        return UserViewModel(name: user.name, login: user.login)
    }
}
