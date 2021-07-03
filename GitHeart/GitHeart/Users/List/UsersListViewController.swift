//
//  UsersListViewController.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

class UsersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private let viewModel: UsersListViewModel

    private let activityIndicatorView: LineActivityIndicatorView = {
        let indicator = LineActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 3.0))
        indicator.barColor = Colors.tintColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 60.0))
        searchBar.placeholder = "Search by name or nickname"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.rowHeight = 60.0
        tableView.backgroundColor = Colors.background
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.tableHeaderView = searchBar
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = Colors.primaryTextColor.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var statusLabelCenterYConstraint: NSLayoutConstraint?

    var didTapUser: ((User) -> Void)?

    init(viewModel: UsersListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = NavigationView(frame: CGRect.zero)

        view.backgroundColor = Colors.background
        view.addSubview(tableView)
        view.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        viewModel.didChangeLoading = { [weak self] isLoading in
            self?.updateStatusLabel()
            self?.setActivityIndicator(visible: isLoading)
        }
        viewModel.didUpdateUsersList = { [weak self] in
            self?.updateStatusLabel()
            self?.tableView.reloadData()
        }
        viewModel.didFail = { [weak self] error in self?.show(error: error) }

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarTransparency()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func show(error: Error) {
        let alert = UIAlertController.error(error, tryAgainHandler: { [weak self] in
            self?.viewModel.load()
        })
        present(alert, animated: true, completion: nil)
    }

    private func setActivityIndicator(visible: Bool) {
        activityIndicatorView.isHidden = !visible
        if visible {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    private func updateStatusLabel() {
        if let statusText = viewModel.statusText {
            statusLabel.text = statusText
            if statusLabel.superview == nil {
                view.addSubview(statusLabel)
                statusLabelCenterYConstraint = statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                NSLayoutConstraint.activate([
                    statusLabelCenterYConstraint!,
                    statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
                    statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0),
                ])
                syncStatusLabelPositionWithTableView()
            }
        } else {
            statusLabel.removeFromSuperview()
            statusLabelCenterYConstraint = nil
        }
    }

    private func syncStatusLabelPositionWithTableView() {
        statusLabelCenterYConstraint?.constant = (tableView.contentOffset.y + view.safeAreaInsets.top) * -1.0
    }

    private func updateNavigationBarTransparency() {
        let y = tableView.contentOffset.y + view.safeAreaInsets.top
        navigationController?.navigationBar.setNavigationBarTransparent(y <= 0.0)
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfUsers()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        cell.configure(viewModel.userViewModel(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true) // End editing in search bar.
        didTapUser?(viewModel.user(at: indexPath.row))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        syncStatusLabelPositionWithTableView()
        updateNavigationBarTransparency()
        let bottomPosition = scrollView.contentOffset.y + scrollView.bounds.size.height
        if bottomPosition > scrollView.contentSize.height - 200.0 {
            viewModel.load()
        }
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        viewModel.applySearch(text: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.applySearch(text: "")
    }

    func searchBarSearchButtonClicked(_: UISearchBar) {
        view.endEditing(true)
    }
}

private class NavigationView: UIView {
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
