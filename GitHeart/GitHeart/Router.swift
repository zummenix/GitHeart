//
//  Router.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 23.06.2021.
//

import UIKit

class Router {
    let window: UIWindow
    let imageProvider: ImageProvider
    let api: API

    init(window: UIWindow, imageProvider: ImageProvider) {
        self.window = window
        self.imageProvider = imageProvider
        api = API()
        window.tintColor = Colors.tintColor
    }

    func start() {
        let controller = UsersListViewController(viewModel: UsersListViewModel(api: api, imageProvider: imageProvider))
        controller.didTapUser = { [weak self] user in self?.showUserDetails(user) }
        window.rootViewController = UINavigationController(rootViewController: controller)
    }

    private func showUserDetails(_ user: User) {
        let controller = UserDetailsViewController(viewModel: UserDetailsViewModel(user: user, api: api, imageProvider: imageProvider))
        window.rootViewController?.show(controller, sender: nil)
    }
}
