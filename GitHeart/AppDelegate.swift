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
        window!.makeKeyAndVisible()
        router = composeMainRouter()
        router.start()
        return true
    }

    func applicationDidReceiveMemoryWarning(_: UIApplication) {
        imageCache.freeMemory()
    }

    private func composeMainRouter() -> MainRouter {
        let session = URLSession.shared
        let imageService = ImageService(session: session, cache: imageCache)
        let apiCore = APICore(token: Env().githubAccessToken, session: session)
        return MainRouter(window: window!, dependencies: MainRouter.Dependencies(
            imageProvider: {
                imageService
            }, usersSearchDebounder: {
                DispatchQueueDebouncer(timeInterval: .seconds(1))
            }, usersListProvider: {
                apiCore
            }, userDetailsProvider: {
                apiCore
            }
        ))
    }
}
