//
//  AppDelegate.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 23.06.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let imageCache = MemoryCache<URL, Data>(maxByteSize: 10 * 1024 * 1024)
    private var router: Router!
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window!.tintColor = Colors.tintColor
        window!.makeKeyAndVisible()

        let navigationController = UINavigationController()
        window!.rootViewController = navigationController

        router = composeMainRouter(navigationController: navigationController)
        router.start()
        return true
    }

    func applicationDidReceiveMemoryWarning(_: UIApplication) {
        imageCache.freeMemory()
    }

    private func composeMainRouter(navigationController: UINavigationController) -> MainRouter {
        let session = URLSession.shared
        let imageService = ImageService(session: session, cache: imageCache)
        let usersService = UsersService(apiCore: APICore(token: Env.githubAccessToken, session: session))
        return MainRouter(navigationController: navigationController, dependencies: MainRouter.Dependencies(
            usersListFactory: { didTapUser in
                let controller = UsersListViewController(
                    viewModel: UsersListViewModel(
                        usersListProvider: usersService,
                        imageProvider: imageService,
                        searchDebouncer: DispatchQueueDebouncer(timeInterval: .seconds(1))
                    )
                )
                controller.didTapUser = didTapUser
                return controller
            }, userDetailsFactory: { user, didTapShareUserUrl in
                let controller = UserDetailsViewController(
                    viewModel: UserDetailsViewModel(
                        user: user,
                        userDetailsProvider: usersService,
                        imageProvider: imageService
                    )
                )
                controller.didTapShareUserUrl = didTapShareUserUrl
                return controller
            }, activityFactory: { url, sender in
                let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                controller.popoverPresentationController?.barButtonItem = sender
                return controller
            }
        ))
    }
}
