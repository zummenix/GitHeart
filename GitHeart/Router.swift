//
//  Router.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 23.06.2021.
//

import UIKit

/// A type that is able to manage navigation from the root of a window.
@MainActor
protocol Router {
    /// Starts routing.
    func start()
}
