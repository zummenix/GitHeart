//
//  Router.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 23.06.2021.
//

import UIKit

class Router {
    private let imagesService = ImagesService(session: URLSession.shared, cache: MemoryCache(maxByteSize: 2 * 1024 * 1024))

    let window: UIWindow
    let api: API

    init(window: UIWindow) {
        self.window = window
        api = API()
        window.tintColor = Colors.tintColor
    }

    func start() {
        let controller = UsersListViewController(viewModel: UsersListViewModel(api: api))
        controller.didTapUser = { [weak self] user in self?.showUserDetails(user) }
        window.rootViewController = UINavigationController(rootViewController: controller)
    }

    private func showUserDetails(_ user: User) {
        let controller = UserDetailsViewController(viewModel: UserDetailsViewModel(user: user, api: api, imagesService: imagesService))
        window.rootViewController?.show(controller, sender: nil)
    }
}
