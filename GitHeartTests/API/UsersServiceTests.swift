//
//  UsersServiceTests.swift
//  GitHeartTests
//
//  Created by Aleksey Kuznetsov on 18.09.2021.
//

@testable import GitHeart
import XCTest

final class UsersServiceTests: XCTestCase {
    func testDecodeUsersList() async throws {
        let sut = try await makeSUT(
            mockedResponse: .success(
                .init(data: data(forResource: "users.json"), headerFields: [:])
            )
        )
        let usersList = try await sut.users(searchTerm: "")
        XCTAssertEqual(usersList.users.count, 30)
    }

    func testExtractNextPageURLForUsersList() async throws {
        let sut = try await makeSUT(
            mockedResponse: .success(
                .init(
                    data: data(forResource: "users.json"),
                    headerFields: ["Link": """
                    <https://api.github.com/search/users?page=2&q=sort%3Afollowers>; rel="next", <https://api.github.com/search/users?page=34&q=sort%3Afollowers>; rel="last"
                    """]
                )
            )
        )

        let usersList = try await sut.users(searchTerm: "")
        XCTAssertEqual(usersList.next, URL(string: "https://api.github.com/search/users?page=2&q=sort%3Afollowers"))
    }

    func testDecodeUserDetails() async throws {
        let sut = try await makeSUT(
            mockedResponse: .success(.init(data: data(forResource: "details.json"), headerFields: [:]))
        )
        let userDetails = try await sut.userDetails(login: "")
        XCTAssertEqual(userDetails.login, "mojombo")
    }

    private func makeSUT(mockedResponse: Result<APICore.Response, Swift.Error>) async -> UsersService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        MockContainer.set(mockedResponse)
        return await UsersService(apiCore: APICore(token: "", session: session))
    }
}

private enum MockContainer {
    private static let lock = NSLock()
    private nonisolated(unsafe) static var result: Result<APICore.Response, Swift.Error> =
        .failure(APICore.Error(message: "Something went wrong"))

    static func set(_ result: Result<APICore.Response, Swift.Error>) {
        lock.withLock { self.result = result }
    }

    static func current() -> Result<APICore.Response, Swift.Error> {
        lock.withLock { result }
    }
}

/// Simple mock for url protocol.
private class MockURLProtocol: URLProtocol {
    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        switch MockContainer.current() {
        case let .success(response):
            client?.urlProtocol(
                self,
                didReceive: HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: response.headerFields as? [String: String]
                )!,
                cacheStoragePolicy: .notAllowed
            )
            client?.urlProtocol(self, didLoad: response.data)
        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
