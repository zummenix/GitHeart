//
//  UserViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 27.06.2021.
//

import Foundation

/// A view model of a user to show it in a list.
struct UserViewModel {
    let login: String
    let avatarUrl: URL?
  // If it's a simple data object, why it contains such a big dependency?
  // That way UserCell is not snapshot-testable now
  // I think it would be appropriate for any image view to use something like a global singleton object.
  // Debatable, of course.
  // Image provider could be configurable that way still, but someone might not like it being a global object :)
  // If you would provide an explanation why it's used here or there - they might understand pros and cons.
    let imageProvider: ImageProvider
}
