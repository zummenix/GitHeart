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
    private var searchDebouncer: Debouncer
    private var users: [User] = []
    private var isLastPage: Bool = false
    private var nextPageURL: URL?

    /// Shows whether the loading is in progress.
    private(set) var isLoading: Bool = false {
        didSet {
            didChangeLoading?(isLoading)
        }
    }

    /// Current search text.
    private(set) var searchText: String = ""

    /// The image provider to request users' avatars.
    let imageProvider: ImageProvider

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

    init(
        usersListProvider: UsersListProvider,
        imageProvider: ImageProvider,
        searchDebouncer: Debouncer = DispatchQueueDebouncer(timeInterval: .seconds(1))
    ) {
        self.usersListProvider = usersListProvider
        self.imageProvider = imageProvider
        self.searchDebouncer = searchDebouncer
    }

    /// Starts loading users from the web.
    ///
    /// The method does nothing if already loads data or if it is a last page.
    func load() {
        guard !isLoading, !isLastPage else { return }
        isLoading = true

        let completion: ((Result<UsersList, Error>) -> Void) = { [weak self] result in
            guard let self = self else { return }
            if !self.isLastPage, self.nextPageURL == nil {
                self.users = []
            }
            self.isLoading = false
            switch result {
            case let .success(usersList):
                self.users.append(contentsOf: usersList.users)
                self.nextPageURL = usersList.next
                self.isLastPage = self.nextPageURL == nil
                self.didUpdateUsersList?()
            case let .failure(error):
                self.didFail?(error)
            }
        }

        if let url = nextPageURL {
            usersListProvider.users(url: url, completion: completion)
        } else {
            usersListProvider.users(searchTerm: searchText, completion: completion)
        }
    }

    /// Applies search text, and starts loading.
    ///
    /// The method debounces to mitigate rate limiting issues and improve performance.
    func applySearch(text: String) {
        guard searchText != text else { return }
        searchText = text
        isLastPage = false
        nextPageURL = nil

        searchDebouncer.debounce { [weak self] in
            guard let self = self else { return }
            if self.isLoading {
                self.applySearch(text: self.searchText)
            } else {
                self.load()
            }
        }
    }

    /// Returns number of users in the list.
    func numberOfUsers() -> Int {
        return users.count
    }

    /// Returns a view data of a user to show in a cell.
    func userViewData(at index: Int) -> UserViewData {
        let user = self.user(at: index)
        return UserViewData(login: user.login, avatarUrl: user.avatarUrl)
    }

    /// Returns model of a user.
    func user(at index: Int) -> User {
        return users[index]
    }
}
