//
//  UsersListViewController.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

/// A view controlelr for the list of users.
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
        searchBar.placeholder = "Name, Nickname or GitHub search query"
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

    /// Called when the user taps a cell with a user.
    var didTapUser: ((User) -> Void)?

    init(viewModel: UsersListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = NavigationLogoView(frame: CGRect.zero)

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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
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

    private func isTableViewUnderNavigationBar() -> Bool {
        tableView.contentOffset.y + view.safeAreaInsets.top > 0.0
    }

    private func updateNavigationBarTransparency() {
        navigationController?.navigationBar.setNavigationBarTransparent(!isTableViewUnderNavigationBar())
    }

    private func adjustTableViewBottomInset(_ value: CGFloat) {
        tableView.contentInset.bottom = value
        tableView.verticalScrollIndicatorInsets.bottom = value
    }

    @objc private func keyboardWillShowNotification(_ notification: Notification) {
        let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        adjustTableViewBottomInset(endFrame.size.height - view.safeAreaInsets.bottom)
    }

    @objc private func keyboardWillHideNotification(_: Notification) {
        adjustTableViewBottomInset(0.0)
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.numberOfUsers()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        cell.configure(viewModel.userViewData(at: indexPath.row), imageProvider: viewModel.imageProvider)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isTableViewUnderNavigationBar() {
            view.endEditing(true) // End editing to avoid autoscroll to the top when user gets back.
        }
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

    func searchBarTextDidBeginEditing(_: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_: UISearchBar) {
        searchBar.setShowsCancelButton(!viewModel.searchText.isEmpty, animated: true)
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        viewModel.applySearch(text: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.applySearch(text: "")
        view.endEditing(true)
    }

    func searchBarSearchButtonClicked(_: UISearchBar) {
        view.endEditing(true)
    }
}
