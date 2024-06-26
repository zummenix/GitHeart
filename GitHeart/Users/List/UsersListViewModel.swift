//
//  UsersListViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import Foundation

/// A view model for the users' list.
@MainActor
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

        Task {
            do {
                let usersList: UsersList = if let url = nextPageURL {
                    try await usersListProvider.users(url: url)
                } else {
                    try await usersListProvider.users(searchTerm: searchText)
                }

                isLoading = false

                if !isLastPage, nextPageURL == nil {
                    users = []
                }
                users.append(contentsOf: usersList.users)
                nextPageURL = usersList.next
                isLastPage = nextPageURL == nil
                didUpdateUsersList?()
            } catch {
                isLoading = false
                didFail?(error)
            }
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
            guard let self else { return }
            if isLoading {
                applySearch(text: searchText)
            } else {
                load()
            }
        }
    }

    /// Returns number of users in the list.
    func numberOfUsers() -> Int {
        users.count
    }

    /// Returns a view data of a user to show in a cell.
    func userViewData(at index: Int) -> UserViewData {
        let user = user(at: index)
        return UserViewData(login: user.login, avatarUrl: user.avatarUrl)
    }

    /// Returns model of a user.
    func user(at index: Int) -> User {
        users[index]
    }
}
