//
//  NavigationLogoView.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 04.07.2021.
//

import UIKit

/// The logo view to show on a navigation bar.
class NavigationLogoView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let gitLabel = UILabel()
        gitLabel.text = "Git"
        gitLabel.textColor = Colors.primaryTextColor
        gitLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        gitLabel.translatesAutoresizingMaskIntoConstraints = false

        let logoImageView = UIImageView(image: UIImage(named: "logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(gitLabel)
        addSubview(logoImageView)

        NSLayoutConstraint.activate([
            gitLabel.leftAnchor.constraint(equalTo: leftAnchor),
            gitLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            gitLabel.rightAnchor.constraint(equalTo: logoImageView.leftAnchor, constant: -6.0),

            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 30.0),
            logoImageView.widthAnchor.constraint(equalToConstant: 30.0),
            logoImageView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
