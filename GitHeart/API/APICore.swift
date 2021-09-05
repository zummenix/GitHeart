//
//  APICore.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 28.06.2021.
//

import Foundation

/// A simple error type for the API.
struct APIError: LocalizedError {
    /// A readable message that typically should be shown to a user.
    let message: String

    var errorDescription: String? {
        return message
    }
}

/// Implements the minimum of necessary logic for the project to work with the github API.
class APICore {
    private static let errorsByStatusCode: [Int: APIError] = [
        401: APIError(message: "Unauthorized"),
        403: APIError(message: "Rate Limited or Forbidden"),
        422: APIError(message: "Unprocessable Entity"),
        503: APIError(message: "Service Unavailable"),
    ]

    private let baseURL = URL(string: "https://api.github.com")!
    private let token: String
    private let session: URLSession
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(token: String, session: URLSession) {
        self.token = token
        self.session = session
    }

    /// Formats a GET request to the API using `path` and `query`.
    func makeGETRequest(path: String, query: [String: String]) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = path
        urlComponents.queryItems = query.map { name, value -> URLQueryItem in
            URLQueryItem(name: name, value: value)
        }
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        if !token.isEmpty {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// Performs the request and decodes the result.
    ///
    /// The completion block will be called on a queue of the `URLSession` provided in `init`.
    func perform<T: Decodable>(request: URLRequest, completion: @escaping ((Result<T, Error>) -> Void)) {
        let task = session.dataTask(with: request) { [jsonDecoder] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
                if let error = APICore.errorsByStatusCode[response.statusCode] {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError(message: "Service Unknown Failure")))
                }
                return
            }

            if let data = data {
                do {
                    let result = try jsonDecoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(APIError(message: "Empty Response")))
            }
        }
        task.resume()
    }
}

extension APICore: UsersListProvider {
    func users(searchTerm: String, page: Int, completion: @escaping ((Result<[User], Error>) -> Void)) {
        let query = searchTerm.isEmpty ? "sort:followers" : searchTerm
        perform(request: makeGETRequest(path: "/search/users", query: ["q": query, "page": String(page)]), completion: { result in
            DispatchQueue.main.async {
                completion(result.map { (paginated: PaginatedUsers) in paginated.items })
            }
        })
    }
}

extension APICore: UserDetailsProvider {
    func userDetails(login: String, completion: @escaping (Result<UserDetails, Error>) -> Void) {
        perform(request: makeGETRequest(path: "/users/\(login)", query: [:])) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
