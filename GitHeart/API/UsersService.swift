//
//  UsersService.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 16.09.2021.
//

import Foundation

/// Responsible for providing API interface to users.
@MainActor
class UsersService: UsersListProvider, UserDetailsProvider {
    private let apiCore: APICore
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(apiCore: APICore) {
        self.apiCore = apiCore
    }

    func users(searchTerm: String) async throws -> UsersList {
        let query = searchTerm.isEmpty ? "type:user" : searchTerm
        let request = await apiCore.makeGETRequest(path: "/search/users", query: ["q": query, "sort": "followers"])
        return try await users(request: request)
    }

    func users(url: URL) async throws -> UsersList {
        try await users(request: URLRequest(url: url))
    }

    private func users(request: URLRequest) async throws -> UsersList {
        let response = try await apiCore.perform(request: request)
        let paginatedUsers = try await jsonDecoder.decodeAsync(PaginatedUsers.self, from: response.data)
        return UsersList(
            users: paginatedUsers.items,
            next: parseHeaderLink((response.headerFields["Link"] as? String) ?? "")["next"]
        )
    }

    func userDetails(login: String) async throws -> UserDetails {
        let request = await apiCore.makeGETRequest(path: "/users/\(login)", query: [:])
        let response = try await apiCore.perform(request: request)
        return try await jsonDecoder.decodeAsync(UserDetails.self, from: response.data)
    }
}

private extension JSONDecoder {
    func decodeAsync<T>(_ type: T.Type, from data: Data) async throws -> T where T: Decodable & Sendable {
        try await Task.detached { try self.decode(type, from: data) }.value
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
