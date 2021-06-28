//
//  UsersListViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import Foundation

class UsersListViewModel {
    private let api: API
    private var users: [User] = []
    private var page: Int = 1

    var didUpdateState: (() -> Void)?

    init(api: API) {
        self.api = api
    }

    func load() {
        api.users(searchTerm: "", page: page) { [weak self] result in
            switch result {
            case let .success(paginatedUsers):
                self?.users.append(contentsOf: paginatedUsers.items)
                self?.didUpdateState?()
            case let .failure(error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func numberOfUsers() -> Int {
        return users.count
    }

    func userViewModel(at index: Int) -> UserViewModel {
        let user = self.user(at: index)
        return UserViewModel(login: user.login)
    }

    func user(at index: Int) -> User {
        return users[index]
    }
}
