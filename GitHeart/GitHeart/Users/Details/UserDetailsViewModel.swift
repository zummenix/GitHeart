//
//  UserDetailsViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

class UserDetailsViewModel {
    private let user: User
    private let userDetailsProvider: UserDetailsProvider
    private let imageProvider: ImageProvider
    private var imageProviderTask: ImageProviderTask?
    private var userDetails: UserDetails?

    private(set) var isLoading: Bool = false {
        didSet {
            didChangeLoading?(isLoading)
        }
    }

    var didChangeLoading: ((Bool) -> Void)?
    var didLoad: (() -> Void)?
    var didFail: ((Error) -> Void)?

    private(set) var avatarImage: UIImage?

    var name: String {
        return userDetails?.name ?? ""
    }

    var login: String {
        return user.login
    }

    var bio: String {
        return userDetails?.bio ?? ""
    }

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
