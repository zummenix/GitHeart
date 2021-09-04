//
//  MemoryCacheTests.swift
//  GitHeartTests
//
//  Created by Aleksey Kuznetsov on 03.07.2021.
//

@testable import GitHeart
import XCTest

extension String: ByteSizable {
    public var byteSize: Int {
        return count // For testing purposes we count one character as one byte.
    }
}

private func createCache(size: Int = 20) -> MemoryCache<String, String> {
    return MemoryCache(maxByteSize: size)
}

class MemoryCacheTests: XCTestCase {
    func testSetsAndGetsValue() throws {
        let cache = createCache()
        cache.set(value: "a", for: "b")
        XCTAssertEqual(cache.value(forKey: "b"), "a")
    }

    func testTotalSizeChanges() {
        let cache = createCache()
        cache.set(value: "a", for: "a")
        cache.set(value: "bb", for: "bb")
        cache.set(value: "ccc", for: "ccc")
        XCTAssertEqual(cache.totalSize, 6)
        cache.set(value: nil, for: "ccc")
        XCTAssertEqual(cache.totalSize, 3)
        cache.removeAll()
        XCTAssertEqual(cache.totalSize, 0)
    }

    func testEvictsOldValuesAndDoesNotOverflow() {
        let cache = createCache(size: 2)
        cache.set(value: "a", for: "a")
        cache.set(value: "b", for: "b")
        cache.set(value: "c", for: "c")
        XCTAssertNil(cache.value(forKey: "a"))
        XCTAssertEqual(cache.value(forKey: "c"), "c")
        XCTAssertEqual(cache.totalSize, 2)
    }

    func testDoesNotSetValueThatExceedsMaxByteSize() {
        let cache = createCache(size: 2)
        cache.set(value: "aaa", for: "aaa")
        XCTAssertNil(cache.value(forKey: "aaa"))
        XCTAssertEqual(cache.totalSize, 0)
    }

    func testRemovesOldValueForTheSameKey() {
        let cache = createCache(size: 2)
        cache.set(value: "a", for: "a")
        cache.set(value: "b", for: "a")
        XCTAssertEqual(cache.value(forKey: "a"), "b")
        XCTAssertEqual(cache.totalSize, 1)
    }

    func testFreeMemoryRemovesAllData() {
        let cache = createCache()
        cache.set(value: "a", for: "a")
        cache.freeMemory()
        XCTAssertNil(cache.value(forKey: "a"))
        XCTAssertEqual(cache.totalSize, 0)
    }
}
