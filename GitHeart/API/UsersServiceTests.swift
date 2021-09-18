//
//  UsersServiceTests.swift
//  GitHeartTests
//
//  Created by Aleksey Kuznetsov on 18.09.2021.
//

@testable import GitHeart
import XCTest

class UsersServiceTests: XCTestCase {
    func testDecodeUsersList() throws {
        let sut = makeSUT(mockedResponse: .success(.init(data: try data(forResource: "users.json"), headerFields: [:])))
        let exp = expectation(description: "correctly decoded response")
        sut.users(searchTerm: "") { result in
            XCTAssertNotNil(try? result.get())
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testExtractNextPageURLForUsersList() throws {
        let sut = makeSUT(mockedResponse: .success(.init(data: try data(forResource: "users.json"),
                                                         headerFields: ["Link": """
                                                         <https://api.github.com/search/users?page=2&q=sort%3Afollowers>; rel="next", <https://api.github.com/search/users?page=34&q=sort%3Afollowers>; rel="last"
                                                         """])))
        let exp = expectation(description: "correctly decoded response")
        sut.users(searchTerm: "") { result in
            let usersList = try? result.get()
            XCTAssertNotNil(usersList)
            XCTAssertNotNil(usersList?.next)
            XCTAssertEqual(usersList?.next, URL(string: "https://api.github.com/search/users?page=2&q=sort%3Afollowers"))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testDecodeUserDetails() throws {
        let sut = makeSUT(mockedResponse: .success(.init(data: try data(forResource: "details.json"), headerFields: [:])))
        let exp = expectation(description: "correctly decoded response")
        sut.userDetails(login: "") { result in
            XCTAssertNotNil(try? result.get())
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    class APICoreMock: APICore {
        var result: Result<Response, Swift.Error>

        init(token: String, session: URLSession, result: Result<Response, Swift.Error>) {
            self.result = result
            super.init(token: token, session: session)
        }

        override func perform(request _: URLRequest, completion: @escaping ((Result<Response, Swift.Error>) -> Void)) {
            completion(result)
        }
    }

    func makeSUT(mockedResponse: Result<APICore.Response, Swift.Error>) -> UsersService {
        return UsersService(apiCore: APICoreMock(token: "", session: URLSession.shared, result: mockedResponse))
    }
}
