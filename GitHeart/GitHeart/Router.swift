//
//  Router.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 23.06.2021.
//

import UIKit

class Router {
    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let controller = UsersListViewController(viewModel: UsersListViewModel())
        window.rootViewController = UINavigationController(rootViewController: controller)
    }
}
