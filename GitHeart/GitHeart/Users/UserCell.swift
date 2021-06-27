//
//  UserCell.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import UIKit

class UserCell: UITableViewCell {
    static let identifier = String(describing: UserCell.self)

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
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = Colors.primaryTextColor
        return label
    }()

    private let loginLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = Colors.secondaryTextColor
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, loginLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Colors.background

        backgroundView = UIView()
        backgroundView?.backgroundColor = Colors.background

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = Colors.backgroundSelection

        contentView.addSubview(avatarImageView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),

            stackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10.0),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
        separatorInset = UIEdgeInsets(top: 0.0, left: stackView.frame.origin.x, bottom: 0.0, right: 0.0)
    }

    func configure(_ viewModel: UserViewModel) {
        nameLabel.text = viewModel.name
        loginLabel.text = viewModel.login
    }
}
