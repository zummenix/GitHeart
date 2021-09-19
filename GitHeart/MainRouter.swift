//
//  MainRouter.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 09.09.2021.
//

import UIKit

/// The main router of the app.
class MainRouter: Router {
    struct Dependencies {
        let imageProvider: () -> ImageProvider
        let usersSearchDebounder: () -> Debouncer
        let usersListProvider: () -> UsersListProvider
        let userDetailsProvider: () -> UserDetailsProvider
    }

    let navigationController: UINavigationController
    let dependencies: Dependencies

    init(navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = UsersListViewModel(usersListProvider: dependencies.usersListProvider(),
                                           imageProvider: dependencies.imageProvider(),
                                           searchDebouncer: dependencies.usersSearchDebounder())
        let controller = UsersListViewController(viewModel: viewModel)
        controller.didTapUser = { [weak self] user in self?.showUserDetails(user) }
        navigationController.show(controller, sender: nil)
    }

    private func showUserDetails(_ user: User) {
        let viewModel = UserDetailsViewModel(user: user,
                                             userDetailsProvider: dependencies.userDetailsProvider(),
                                             imageProvider: dependencies.imageProvider())
        let controller = UserDetailsViewController(viewModel: viewModel)
        controller.didTapShareUserUrl = { [weak self] url in self?.showActivityFor(url: url) }
        navigationController.show(controller, sender: nil)
    }

    private func showActivityFor(url: URL) {
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        navigationController.present(ac, animated: true, completion: nil)
    }
}
