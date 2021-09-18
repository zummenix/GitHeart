//
//  APICore.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 28.06.2021.
//

import Foundation

/// Implements the minimum of necessary logic for the project to work with the github API.
class APICore {
    /// A response representation for the API.
    struct Response {
        let data: Data
        let headerFields: [AnyHashable: Any]
    }

    /// A simple error type for the API.
    struct Error: LocalizedError {
        /// A readable message that typically should be shown to a user.
        let message: String

        var errorDescription: String? {
            return message
        }
    }

    private static let errorsByStatusCode: [Int: Error] = [
        401: Error(message: "Unauthorized"),
        403: Error(message: "Rate Limited or Forbidden"),
        422: Error(message: "Unprocessable Entity"),
        503: Error(message: "Service Unavailable"),
    ]

    private let baseURL = URL(string: "https://api.github.com")!
    private let token: String
    private let session: URLSession

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
        return URLRequest(url: urlComponents.url!)
    }

    /// Returns the modified request by adding necessary headers.
    ///
    /// This method is called right before performing the request.
    func modified(request: URLRequest) -> URLRequest {
        var request = request
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        if !token.isEmpty {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// Performs the request.
    ///
    /// The completion block will be called on a queue of the `URLSession` provided in `init`.
    func perform(request: URLRequest, completion: @escaping ((Result<Response, Swift.Error>) -> Void)) {
        let task = session.dataTask(with: modified(request: request)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            var headerFields: [AnyHashable: Any] = [:]
            if let response = response as? HTTPURLResponse {
                if response.statusCode >= 400 {
                    if let error = APICore.errorsByStatusCode[response.statusCode] {
                        completion(.failure(error))
                    } else {
                        completion(.failure(Error(message: "Service Unknown Failure")))
                    }
                    return
                }
                headerFields = response.allHeaderFields
            }

            if let data = data, !data.isEmpty {
                completion(.success(Response(data: data, headerFields: headerFields)))
            } else {
                completion(.failure(Error(message: "Empty Response")))
            }
        }
        task.resume()
    }
}
