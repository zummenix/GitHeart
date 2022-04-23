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
        let usersListFactory: (_ didTapUser: @escaping (User) -> Void) -> UIViewController
        let userDetailsFactory: (_ user: User, _ didTapShareUserUrl: @escaping (URL) -> Void) -> UIViewController
        let activityFactory: (_ url: URL) -> UIViewController
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
        let controller = dependencies.userDetailsFactory(user) { [weak self] url in self?.showActivityFor(url: url) }
        navigationController.show(controller, sender: nil)
    }

    private func showActivityFor(url: URL) {
        navigationController.present(dependencies.activityFactory(url), animated: true, completion: nil)
    }
}
