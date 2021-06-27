//
//  UserDetailsViewController.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import UIKit

class UserDetailsViewController: UIViewController {
    private let viewModel: UserDetailsViewModel

    init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
    }
}
