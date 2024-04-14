//
//  APICore.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 28.06.2021.
//

import Foundation

/// Implements the minimum of necessary logic for the project to work with the github API.
actor APICore {
    /// A response representation for the API.
    struct Response {
        let data: Data
        let headerFields: [String: Sendable]
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
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if !token.isEmpty {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// Performs the request.
    func perform(request: URLRequest) async throws -> Response {
        let (data, response) = try await session.my_data(for: modified(request: request))
        var headerFields: [String: Sendable] = [:]
        if let response = response as? HTTPURLResponse {
            if response.statusCode >= 400 {
                if let error = APICore.errorsByStatusCode[response.statusCode] {
                    throw error
                } else {
                    throw Error(message: "Service Unknown Failure")
                }
            }
            headerFields = (response.allHeaderFields as? [String: Sendable]) ?? [:]
        }

        if data.isEmpty {
            throw Error(message: "Empty Response")
        } else {
            return Response(data: data, headerFields: headerFields)
        }
    }
}

private extension URLSession {
    // Without this method there is a warning `Passing argument of non-sendable type '(any URLSessionTaskDelegate)?'
    // outside of actor-isolated context may introduce data races`
    func my_data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}
