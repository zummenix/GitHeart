//
//  UserCell.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import UIKit

/// A cell to show a user.
class UserCell: UITableViewCell {
    static let identifier = String(describing: UserCell.self)

    private let avatarImageView: WebImageView = {
        let imageView = WebImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Colors.secondaryBackground
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let loginLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = Colors.primaryTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Colors.background
        accessoryType = .disclosureIndicator

        backgroundView = UIView()
        backgroundView?.backgroundColor = Colors.background

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = Colors.backgroundSelection

        contentView.addSubview(avatarImageView)
        contentView.addSubview(loginLabel)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),

            loginLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10.0),
            loginLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            loginLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
        separatorInset = UIEdgeInsets(top: 0.0, left: loginLabel.frame.origin.x, bottom: 0.0, right: 0.0)
    }

    /// Configures the cell with a view model of a user.
    func configure(_ viewModel: UserViewModel) {
        loginLabel.text = viewModel.login
        avatarImageView.setImage(url: viewModel.avatarUrl, imageProvider: viewModel.imageProvider)
    }
}
