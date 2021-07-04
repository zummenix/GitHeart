//
//  UserDetailsContentView.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 04.07.2021.
//

import UIKit

/// A content view for user's details.
class UserDetailsContentView: UIView {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Colors.secondaryBackground
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = Colors.primaryTextColor
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.isHidden = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let loginLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = Colors.secondaryTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let followersFollowingReposLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bioLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = Colors.primaryTextColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(activityIndicatorView)
        addSubview(loginLabel)
        addSubview(followersFollowingReposLabel)
        addSubview(bioLabel)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 200.0),
            avatarImageView.heightAnchor.constraint(equalToConstant: 200.0),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20.0),
            nameLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            activityIndicatorView.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2.0),
            loginLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            followersFollowingReposLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 20.0),
            followersFollowingReposLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            followersFollowingReposLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            bioLabel.topAnchor.constraint(equalTo: followersFollowingReposLabel.bottomAnchor, constant: 20.0),
            bioLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            bioLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2.0
    }

    /// Configures the view with content data.
    func configure(data: UserDetailsContentData) {
        avatarImageView.image = data.avatarImage
        nameLabel.text = data.name
        loginLabel.text = data.login
        followersFollowingReposLabel.attributedText = data.followersFollowingRepos
        bioLabel.text = data.bio
    }

    /// Sets activity indicator visible for the view.
    func setActivityIndicator(visible: Bool) {
        activityIndicatorView.isHidden = !visible
        nameLabel.isHidden = visible
        if visible {
            if nameLabel.text?.isEmpty ?? true {
                nameLabel.text = " " // The label should have the height to avoid jitter and to position the activity indicator.
            }
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}
