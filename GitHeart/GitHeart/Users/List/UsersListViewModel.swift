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
    private var searchText: String = ""
    private var page: Int = 1
    private var isLoading: Bool = false
    private var isLastPage: Bool = false
    private var searchWorkItem: DispatchWorkItem?
    private let thumbnailImageService = ImageService(session: URLSession.shared, cache: MemoryCache(maxByteSize: 10 * 1024 * 1024))

    var didUpdateState: (() -> Void)?

    init(api: API) {
        self.api = api
    }

    func load() {
        isLoading = true
        print("Loading page \(page), search: \(searchText)")
        api.users(searchTerm: searchText, page: page) { [weak self] result in
            guard let self = self else { return }
            if self.page == 1 {
                self.users = []
            }
            self.isLoading = false
            switch result {
            case let .success(paginatedUsers):
                self.users.append(contentsOf: paginatedUsers.items)
                self.isLastPage = paginatedUsers.items.isEmpty
                self.didUpdateState?()
            case let .failure(error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func loadNextPageIfPossible() {
        guard !isLoading, !isLastPage else { return }
        page += 1
        load()
    }

    func applySearch(text: String) {
        searchText = text
        page = 1
        isLastPage = false

        searchWorkItem?.cancel()
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.isLoading {
                self.applySearch(text: self.searchText)
            } else {
                self.load()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: searchWorkItem!)
    }

    func numberOfUsers() -> Int {
        return users.count
    }

    func userViewModel(at index: Int) -> UserViewModel {
        let user = self.user(at: index)
        return UserViewModel(login: user.login, avatarUrl: user.avatarUrl, imageService: thumbnailImageService)
    }

    func user(at index: Int) -> User {
        return users[index]
    }
}
