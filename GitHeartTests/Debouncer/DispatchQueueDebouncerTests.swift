//
//  DispatchQueueDebouncerTests.swift
//  GitHeartTests
//
//  Created by Aleksey Kuznetsov on 12.07.2021.
//

@testable import GitHeart
import XCTest

class DispatchQueueDebouncerTests: XCTestCase {
    func testMultipleCallsWithDebounce() {
        let expectation = XCTestExpectation()
        let counter = Counter(value: 0)
        var debouncer = DispatchQueueDebouncer(timeInterval: .milliseconds(100))
        debouncer.debounce {
            counter.value += 1
            expectation.fulfill()
        }
        debouncer.debounce {
            counter.value += 1
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(counter.value, 1)
    }

    func testMultipleCallsWithoutDebounce() {
        var expectation = XCTestExpectation()

        let counter = Counter(value: 0)
        var debouncer = DispatchQueueDebouncer(timeInterval: .milliseconds(100))
        debouncer.debounce {
            counter.value += 1
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        expectation = XCTestExpectation()
        debouncer.debounce {
            counter.value += 1
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(counter.value, 2)
    }
}

class Counter {
    var value: Int
    init(value: Int) {
        self.value = value
    }
}
