//
//  UsersService.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 16.09.2021.
//

import Foundation

class UsersService {
    private let apiCore: APICore
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(apiCore: APICore) {
        self.apiCore = apiCore
    }
}

extension UsersService: UsersListProvider {
    func users(searchTerm: String, page: Int, completion: @escaping ((Result<UsersList, Error>) -> Void)) {
        let query = searchTerm.isEmpty ? "sort:followers" : searchTerm
        apiCore.perform(request: apiCore.makeGETRequest(path: "/search/users", query: ["q": query, "page": String(page)]), completion: { [jsonDecoder] result in
            let result = result.flatMap { response in
                Result { try jsonDecoder.decode(PaginatedUsers.self, from: response.data) }.map { paginatedUsers in
                    UsersList(users: paginatedUsers.items, next: nil)
                }
            }
            DispatchQueue.main.async {
                completion(result)
            }
        })
    }
}

extension UsersService: UserDetailsProvider {
    func userDetails(login: String, completion: @escaping (Result<UserDetails, Error>) -> Void) {
        apiCore.perform(request: apiCore.makeGETRequest(path: "/users/\(login)", query: [:])) { [jsonDecoder] result in
            let result = result.flatMap { response in
                Result { try jsonDecoder.decode(UserDetails.self, from: response.data) }
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
