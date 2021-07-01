//
//  Router.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 23.06.2021.
//

import UIKit

class Router {
    let window: UIWindow
    let imageService: ImageService
    let api: API

    init(window: UIWindow, imageService: ImageService) {
        self.window = window
        self.imageService = imageService
        api = API()
        window.tintColor = Colors.tintColor
    }

    func start() {
        let controller = UsersListViewController(viewModel: UsersListViewModel(api: api, imageService: imageService))
        controller.didTapUser = { [weak self] user in self?.showUserDetails(user) }
        window.rootViewController = UINavigationController(rootViewController: controller)
    }

    private func showUserDetails(_ user: User) {
        let controller = UserDetailsViewController(viewModel: UserDetailsViewModel(user: user, api: api, imageService: imageService))
        window.rootViewController?.show(controller, sender: nil)
    }
}
