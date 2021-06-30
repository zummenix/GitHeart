//
//  UserDetailsViewController.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

class UserDetailsViewController: UIViewController {
    private let viewModel: UserDetailsViewModel

    private let avatarImageView: WebImageView = {
        let imageView = WebImageView(frame: .zero)
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = Colors.secondaryTextColor
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

    private let followersFollowingReposLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background

        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(bioLabel)
        view.addSubview(followersFollowingReposLabel)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 200.0),
            avatarImageView.heightAnchor.constraint(equalToConstant: 200.0),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20.0),
            nameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2.0),
            loginLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            bioLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 20.0),
            bioLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            followersFollowingReposLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 20.0),
            followersFollowingReposLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            followersFollowingReposLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])

        reloadData()

        viewModel.didLoad = { [weak self] in self?.reloadData() }
        viewModel.didFail = { [weak self] error in self?.show(error: error) }

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setNavigationBarTransparent(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2.0
    }

    private func show(error: Error) {
        let alert = UIAlertController.error(error, tryAgainHandler: { [weak self] in
            self?.viewModel.load()
        })
        present(alert, animated: true, completion: nil)
    }

    private func reloadData() {
        avatarImageView.setImage(url: viewModel.avatarUrl, imageService: viewModel.imageService)
        nameLabel.text = viewModel.name
        loginLabel.text = viewModel.login
        bioLabel.text = viewModel.bio
        followersFollowingReposLabel.attributedText = viewModel.followersFollowingRepos
    }
}
