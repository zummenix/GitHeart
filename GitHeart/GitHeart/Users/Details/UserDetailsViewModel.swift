//
//  UserDetailsViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

class UserDetailsViewModel {
    private let user: User
    private let api: API
    let imageService: ImageService
    private var userDetails: UserDetails?

    var didLoad: (() -> Void)?
    var didFail: ((Error) -> Void)?

    var avatarUrl: URL? {
        return userDetails?.avatarUrl ?? user.avatarUrl
    }

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

    init(user: User, api: API, imageService: ImageService) {
        self.user = user
        self.api = api
        self.imageService = imageService
    }

    func load() {
        api.userDetails(login: user.login) { [weak self] result in
            switch result {
            case let .success(userDetails):
                self?.userDetails = userDetails
                self?.didLoad?()
            case let .failure(error):
                self?.didFail?(error)
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
