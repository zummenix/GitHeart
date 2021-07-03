//
//  UserDetailsViewController.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

/// A view controller for the user's details.
class UserDetailsViewController: UIViewController {
    private let viewModel: UserDetailsViewModel

    private lazy var shareBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        return button
    }()

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

    /// Called when user taps share user's GitHub page.
    var didTapShareUserUrl: ((URL) -> Void)?

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

        navigationItem.rightBarButtonItem = shareBarButtonItem

        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(activityIndicatorView)
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

            activityIndicatorView.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

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

        viewModel.didChangeLoading = { [weak self] isVisible in self?.setActivityIndicator(visible: isVisible) }
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
        avatarImageView.image = viewModel.avatarImage
        nameLabel.text = viewModel.name
        loginLabel.text = viewModel.login
        bioLabel.text = viewModel.bio
        followersFollowingReposLabel.attributedText = viewModel.followersFollowingRepos
    }

    private func setActivityIndicator(visible: Bool) {
        shareBarButtonItem.isEnabled = !visible
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

    @objc private func share(_: UIBarButtonItem) {
        guard let url = viewModel.userUrl else { return }
        didTapShareUserUrl?(url)
    }
}
