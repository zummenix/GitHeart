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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UserDetailsContentView = {
        let view = UserDetailsContentView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Called when user taps share user's GitHub page.
    var didTapShareUserUrl: ((URL, UIBarButtonItem) -> Void)?

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

        navigationItem.rightBarButtonItem = shareBarButtonItem

        view.backgroundColor = Colors.background
        scrollView.backgroundColor = view.backgroundColor
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])

        reloadData()

        viewModel.didChangeLoading = { [weak self] isVisible in self?.contentView.setActivityIndicator(visible: isVisible) }
        viewModel.didLoad = { [weak self] in self?.reloadData() }
        viewModel.didFail = { [weak self] error in self?.show(error: error) }

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setNavigationBarTransparent(true)
    }

    private func show(error: Error) {
        let alert = UIAlertController.error(error, tryAgainHandler: { [weak self] in
            self?.viewModel.load()
        })
        present(alert, animated: true, completion: nil)
    }

    private func reloadData() {
        shareBarButtonItem.isEnabled = viewModel.userUrl != nil
        contentView.configure(viewModel.contentViewData())
    }

    @objc private func share(_ sender: UIBarButtonItem) {
        guard let url = viewModel.userUrl else { return }
        didTapShareUserUrl?(url, sender)
    }
}
