//
//  UsersListViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import Foundation

/// A view model for the users' list.
class UsersListViewModel {
    private let usersListProvider: UsersListProvider
    private let imageProvider: ImageProvider
    private var users: [User] = []
    private var searchText: String = ""
    private var page: Int = 1 // The number of a page that will be requested next.

    private var isLastPage: Bool = false
    private var searchWorkItem: DispatchWorkItem?

    /// Shows whether the loading is in progress.
    private(set) var isLoading: Bool = false {
        didSet {
            didChangeLoading?(isLoading)
        }
    }

    /// The status text related to loading and empty state.
    var statusText: String? {
        if users.isEmpty {
            return isLoading ? "Loading..." : "Nothing Found"
        }
        return nil
    }

    /// Called when the loading status changes.
    var didChangeLoading: ((Bool) -> Void)?
    /// Called when there are changes in the list of users.
    var didUpdateUsersList: (() -> Void)?
    /// Called when an error has occurred.
    var didFail: ((Error) -> Void)?

    init(usersListProvider: UsersListProvider, imageProvider: ImageProvider) {
        self.usersListProvider = usersListProvider
        self.imageProvider = imageProvider
    }

    /// Starts loading users from the web.
    ///
    /// The method does nothing if already loads data or if it is a last page.
    func load() {
        guard !isLoading, !isLastPage else { return }
        isLoading = true
        usersListProvider.users(searchTerm: searchText, page: page) { [weak self] result in
            guard let self = self else { return }
            if self.page == 1 {
                self.users = []
            }
            self.isLoading = false
            switch result {
            case let .success(users):
                self.users.append(contentsOf: users)
                self.isLastPage = users.isEmpty
                self.page += 1
                self.didUpdateUsersList?()
            case let .failure(error):
                self.didFail?(error)
            }
        }
    }

    /// Applies search text, and starts loading.
    ///
    /// The method throttles to mitigate rate limiting issues and improve performance.
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

    /// Returns number of users in the list.
    func numberOfUsers() -> Int {
      // Return is not required on one-liners
        return users.count
    }

    /// Returns a view model of a user to show in a cell.
    func userViewModel(at index: Int) -> UserViewModel {
        let user = self.user(at: index)
        return UserViewModel(login: user.login, avatarUrl: user.avatarUrl, imageProvider: imageProvider)
    }

    /// Returns model of a user.
    func user(at index: Int) -> User {
        return users[index]
    }
}
