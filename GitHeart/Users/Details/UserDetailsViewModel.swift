//
//  UserDetailsViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

/// A view model for the user details.
@MainActor
class UserDetailsViewModel {
    private let user: User
    private let userDetailsProvider: UserDetailsProvider
    private let imageProvider: ImageProvider
    private var imageProviderTask: Task<Void, Never>?
    private var userDetails: UserDetails?

    private var avatarImage: UIImage?

    /// Shows whether the loading is in progress.
    private(set) var isLoading: Bool = false {
        didSet {
            didChangeLoading?(isLoading)
        }
    }

    /// Called when the loading status changes.
    var didChangeLoading: ((Bool) -> Void)?
    /// Called when loading is done.
    var didLoad: (() -> Void)?
    /// Called when an error has occurred.
    var didFail: ((Error) -> Void)?

    /// The url of a user's page on GitHub.
    var userUrl: URL? {
        return userDetails?.htmlUrl
    }

    init(user: User, userDetailsProvider: UserDetailsProvider, imageProvider: ImageProvider) {
        self.user = user
        self.userDetailsProvider = userDetailsProvider
        self.imageProvider = imageProvider
    }

    /// Starts loading user details from the web.
    func load() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                let userDetails = try await userDetailsProvider.userDetails(login: user.login)
                isLoading = false
                self.userDetails = userDetails
                didLoad?()
            } catch {
                isLoading = false
                didFail?(error)
            }
        }

        imageProviderTask?.cancel()
        if let avatarUrl = user.avatarUrl {
            imageProviderTask = Task {
                avatarImage = await imageProvider.imageBy(url: avatarUrl)
                didLoad?()
            }
        }
    }

    /// Returns content view data to show on screen.
    func contentViewData() -> UserDetailsContentViewData {
        var stats: UserDetailsContentViewData.Stats?
        if let userDetails = userDetails {
            stats = UserDetailsContentViewData.Stats(followers: userDetails.followers, following: userDetails.following,
                                                     publicRepos: userDetails.publicRepos)
        }
        return UserDetailsContentViewData(avatarImage: avatarImage, login: user.login, name: userDetails?.name ?? "",
                                          stats: stats, bio: userDetails?.bio ?? "")
    }
}
