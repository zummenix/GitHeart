//
//  UsersService.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 16.09.2021.
//

import Foundation

class UsersService {
    private let apiCore: APICore

    init(apiCore: APICore) {
        self.apiCore = apiCore
    }
}

extension UsersService: UsersListProvider {
    func users(searchTerm: String, page: Int, completion: @escaping ((Result<UsersList, Error>) -> Void)) {
        let query = searchTerm.isEmpty ? "sort:followers" : searchTerm
        apiCore.perform(request: apiCore.makeGETRequest(path: "/search/users", query: ["q": query, "page": String(page)]), completion: { result in
            DispatchQueue.main.async {
                completion(result.map { (response: APIResponse<PaginatedUsers>) in
                    UsersList(users: response.data.items, next: nil)
                })
            }
        })
    }
}

extension UsersService: UserDetailsProvider {
    func userDetails(login: String, completion: @escaping (Result<UserDetails, Error>) -> Void) {
        apiCore.perform(request: apiCore.makeGETRequest(path: "/users/\(login)", query: [:])) { result in
            DispatchQueue.main.async {
                completion(result.map { $0.data })
            }
        }
    }
}
