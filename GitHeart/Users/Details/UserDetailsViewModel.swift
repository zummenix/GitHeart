//
//  UserDetailsViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

/// A view model for the user details.
class UserDetailsViewModel {
    private let user: User
    private let userDetailsProvider: UserDetailsProvider
    private let imageProvider: ImageProvider
    private var imageProviderTask: ImageProviderTask?
    private var userDetails: UserDetails?

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

    /// The avatar of a user.
    private(set) var avatarImage: UIImage?

    /// The name of a user.
    var name: String {
        return userDetails?.name ?? ""
    }

    /// The login of a user.
    var login: String {
        return user.login
    }

    /// The bio of a user.
    var bio: String {
        return userDetails?.bio ?? ""
    }

    /// The url of a user's page on GitHub.
    var userUrl: URL? {
        return userDetails?.htmlUrl
    }

    /// The formatted string with user's followers, following and repositories counts.
    var followersFollowingRepos: NSAttributedString {
        let string = NSMutableAttributedString()
        if let userDetails = userDetails {
            string.append(compoundString(left: String(userDetails.followers), right: "followers"))
            string.append(separatorString())
            string.append(compoundString(left: String(userDetails.following), right: "following"))
            string.append(NSAttributedString(string: "\n"))
            string.append(compoundString(left: String(userDetails.publicRepos), right: "repositories"))
        }
        return string.centered
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
        userDetailsProvider.userDetails(login: user.login) { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(userDetails):
                self?.userDetails = userDetails
                self?.didLoad?()
            case let .failure(error):
                self?.didFail?(error)
            }
        }
        if let avatarUrl = user.avatarUrl {
            imageProviderTask?.cancel()
            imageProviderTask = imageProvider.imageBy(url: avatarUrl) { [weak self] image in
                self?.avatarImage = image
                self?.didLoad?()
            }
        }
    }
}

private func compoundString(left: String, right: String) -> NSAttributedString {
    let string = NSMutableAttributedString()
    string.append(NSAttributedString(string: left, attributes: [
        NSAttributedString.Key.foregroundColor: Colors.primaryTextColor,
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
    ]))
    string.append(NSAttributedString(string: " \(right)", attributes: [
        NSAttributedString.Key.foregroundColor: Colors.secondaryTextColor,
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline),
    ]))
    return string
}

private func separatorString() -> NSAttributedString {
    return NSAttributedString(string: " · ", attributes: [
        NSAttributedString.Key.foregroundColor: Colors.primaryTextColor,
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
    ])
}

private extension NSMutableAttributedString {
    var centered: Self {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        addAttributes([NSAttributedString.Key.paragraphStyle: style], range: NSRange(location: 0, length: length))
        return self
    }
}
