//
//  UsersService.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 16.09.2021.
//

import Foundation

/// Responsible for providing API interface to users.
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
    func users(searchTerm: String, completion: @escaping ((Result<UsersList, Error>) -> Void)) {
        let query = searchTerm.isEmpty ? "sort:followers" : searchTerm
        users(request: apiCore.makeGETRequest(path: "/search/users", query: ["q": query]), completion: completion)
    }

    func users(url: URL, completion: @escaping ((Result<UsersList, Error>) -> Void)) {
        users(request: URLRequest(url: url), completion: completion)
    }

    private func users(request: URLRequest, completion: @escaping ((Result<UsersList, Error>) -> Void)) {
        apiCore.perform(request: request, completion: { [jsonDecoder] result in
            let result = result.flatMap { response in
                Result { try jsonDecoder.decode(PaginatedUsers.self, from: response.data) }.map { paginatedUsers in
                    UsersList(users: paginatedUsers.items, next: parseHeaderLink((response.headerFields["Link"] as? String) ?? "")["next"])
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

/// Parses a header link and returns a dictionary.
///
/// Example: <https://api.github.com/search/users?page=2&q=sort%3Afollowers>; rel="next",
///          <https://api.github.com/search/users?page=34&q=sort%3Afollowers>; rel="last"
private func parseHeaderLink(_ link: String) -> [String: URL] {
    // Scanner is only available starting from iOS 13, so a workaround:
    var result: [String: URL] = [:]
    for pair in link.components(separatedBy: ",") {
        let parts = pair.components(separatedBy: ";")
        if parts.count == 2 {
            let rawLink = parts[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "<>")))
            let key = parts[1].drop(while: { $0 != "\"" }).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            if let url = URL(string: rawLink) {
                result[key] = url
            }
        }
    }
    return result
}
