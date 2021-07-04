//
//  UserDetailsContentViewData.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 04.07.2021.
//

import UIKit

/// A view data to show on the user's details content view.
struct UserDetailsContentViewData {
    struct Stats {
        let followers: Int
        let following: Int
        let publicRepos: Int
    }

    let avatarImage: UIImage?
    let login: String
    let name: String
    let stats: Stats?
    let bio: String

    var followersFollowingRepos: NSAttributedString {
        let string = NSMutableAttributedString()
        if let stats = stats {
            string.append(compoundString(left: String(stats.followers), right: "followers"))
            string.append(separatorString())
            string.append(compoundString(left: String(stats.following), right: "following"))
            string.append(NSAttributedString(string: "\n"))
            string.append(compoundString(left: String(stats.publicRepos), right: "repositories"))
        }
        return string.centered
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
