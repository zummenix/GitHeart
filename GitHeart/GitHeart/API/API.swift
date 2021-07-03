//
//  API.swift
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
class API {
    private static let errorsByStatusCode: [Int: APIError] = [
        422: APIError(message: "Unprocessable Entity"),
        503: APIError(message: "Service Unavailable"),
    ]

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "https://api.github.com")!, session: URLSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Formats a GET request to the API using `path` and `query`.
    private func request(path: String, query: [String: String]) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = path
        urlComponents.queryItems = query.map { name, value -> URLQueryItem in
            URLQueryItem(name: name, value: value)
        }
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request
    }

    /// Performs the GET request and decodes the result.
    ///
    /// The completion block will be called on a queue of the provided `URLSession`.
    private func get<T: Decodable>(request: URLRequest, decoder: JSONDecoder = defaultJSONDecoder(), completion: @escaping ((Result<T, Error>) -> Void)) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
                if let error = API.errorsByStatusCode[response.statusCode] {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError(message: "Service Unknown Failure")))
                }
                return
            }

            if let data = data {
                do {
                    let result = try decoder.decode(T.self, from: data)
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

extension API: UsersListProvider {
    func users(searchTerm: String, page: Int, completion: @escaping ((Result<[User], Error>) -> Void)) {
        let query = searchTerm.isEmpty ? "followers:>1000" : searchTerm
        get(request: request(path: "/search/users", query: ["q": query, "page": String(page)]), completion: { result in
            DispatchQueue.main.async {
                completion(result.map { (paginated: PaginatedUsers) in paginated.items })
            }
        })
    }
}

extension API: UserDetailsProvider {
    func userDetails(login: String, completion: @escaping (Result<UserDetails, Error>) -> Void) {
        get(request: request(path: "/users/\(login)", query: [:])) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

private func defaultJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}
