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
        router = Router(window: window!, imageProvider: ImageService(session: URLSession.shared, cache: imageCache))
        router.start()
        return true
    }

    func applicationDidReceiveMemoryWarning(_: UIApplication) {
        imageCache.freeMemory()
    }
}
