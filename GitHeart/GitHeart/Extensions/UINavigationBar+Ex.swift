//
//  UINavigationBar+Ex.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import UIKit

extension UINavigationBar {
    /// Switchs the transparency for the navigaton bar.
    func setNavigationBarTransparent(_ isTransparent: Bool) {
        if isTransparent {
            setBackgroundImage(UIImage(), for: .default)
            shadowImage = UIImage()
        } else {
            setBackgroundImage(nil, for: .default)
            shadowImage = nil
        }
    }
}
