//
//  UsersListViewController.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

class UsersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private let viewModel: UsersListViewModel

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 60.0))
        searchBar.placeholder = "Search GitHub Users"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
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
        return tableView
    }()

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
        view.backgroundColor = Colors.background
        view.addSubview(tableView)

        viewModel.didUpdateUsersList = { [weak self] in self?.tableView.reloadData() }
        viewModel.didFail = { [weak self] error in self?.show(error: error) }

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setNavigationBarTransparent(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func show(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in
            self?.viewModel.load()
        }))

        present(alert, animated: true, completion: nil)
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
        didTapUser?(viewModel.user(at: indexPath.row))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomPosition = scrollView.contentOffset.y + scrollView.bounds.size.height
        if bottomPosition > scrollView.contentSize.height - 200.0 {
            viewModel.loadNextPageIfPossible()
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
}
