//
//  UIAlertController+Ex.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 30.06.2021.
//

import UIKit

extension UIAlertController {
    /// Returns simple error alert with optional "Try Again" handler.
    static func error(_ error: Error, tryAgainHandler: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        if let tryAgainHandler {
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                tryAgainHandler()
            }))
        }
        return alert
    }
}
