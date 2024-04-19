//
//  MainRouter.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 09.09.2021.
//

import UIKit

/// The main router of the app.
final class MainRouter: Router {
    struct Dependencies {
        let usersListFactory: (_ didTapUser: @escaping (User) -> Void) -> UIViewController
        let userDetailsFactory: (
            _ user: User,
            _ didTapShareUserUrl: @escaping (URL, UIBarButtonItem) -> Void
        ) -> UIViewController
        let activityFactory: (_ url: URL, UIBarButtonItem) -> UIViewController
    }

    let navigationController: UINavigationController
    let dependencies: Dependencies

    init(navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let controller = dependencies.usersListFactory { [weak self] user in self?.showUserDetails(user) }
        navigationController.show(controller, sender: nil)
    }

    private func showUserDetails(_ user: User) {
        let controller = dependencies.userDetailsFactory(user) { [weak self] url, sender in
            self?.showActivityFor(url: url, sender: sender)
        }
        navigationController.show(controller, sender: nil)
    }

    private func showActivityFor(url: URL, sender: UIBarButtonItem) {
        navigationController.present(dependencies.activityFactory(url, sender), animated: true, completion: nil)
    }
}
