//
//  UserDetailsViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

class UserDetailsViewModel {
    private let user: User
    private var userDetails: UserDetails?

    var name: String {
        return user.name
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
            string.append(separatorString())
            string.append(compoundString(left: String(userDetails.publicRepos), right: "repositories"))
        }
        return string.centered
    }

    init(user: User) {
        self.user = user

        userDetails = UserDetails(name: user.name, login: user.login, bio: "Cool Developer", company: "Company", blog: "My Blog", location: "Location",
                                  email: "user@user.com", followers: 99, following: 111, publicRepos: 123, publicGists: 321)
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
