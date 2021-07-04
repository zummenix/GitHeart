//
//  Router.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 23.06.2021.
//

import UIKit

/// Responsible for presenting and managing view controllers.
class Router {
    let window: UIWindow
    // Dependencies are provided inside a "presenting manager".
    // You might want to use some kind of service factory or a dependencies provider.
    // Just a note about object `responsibilities`
    // Why image provider is coming with init, but api is created here?
    let imageProvider: ImageProvider
    let api: API

    init(window: UIWindow, imageProvider: ImageProvider) {
        self.window = window
        self.imageProvider = imageProvider
        api = API()
        // Might want to use Appearance for this, but it's okay now too.
        window.tintColor = Colors.tintColor
    }

    func start() {
        let viewModel = UsersListViewModel(usersListProvider: api, imageProvider: imageProvider)
        let controller = UsersListViewController(viewModel: viewModel)
        controller.didTapUser = { [weak self] user in self?.showUserDetails(user) }
        window.rootViewController = UINavigationController(rootViewController: controller)
    }

    private func showUserDetails(_ user: User) {
        let viewModel = UserDetailsViewModel(user: user, userDetailsProvider: api, imageProvider: imageProvider)
        let controller = UserDetailsViewController(viewModel: viewModel)
        controller.didTapShareUserUrl = { [weak self] url in self?.showActivityFor(url: url) }
        window.rootViewController?.show(controller, sender: nil)
    }

    private func showActivityFor(url: URL) {
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        window.rootViewController?.present(ac, animated: true, completion: nil)
    }
}
