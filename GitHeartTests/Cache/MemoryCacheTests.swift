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
    func testSetsAndGetsValue() {
        let cache = createCache()
        cache.set(value: "a", for: "b")
        let value = cache.value(forKey: "b")
        XCTAssertEqual(value, "a")
    }

    func testTotalSizeChanges() {
        let cache = createCache()
        cache.set(value: "a", for: "a")
        cache.set(value: "bb", for: "bb")
        cache.set(value: "ccc", for: "ccc")
        var size = cache.totalSize
        XCTAssertEqual(size, 6)
        cache.set(value: nil, for: "ccc")
        size = cache.totalSize
        XCTAssertEqual(size, 3)
        cache.removeAll()
        size = cache.totalSize
        XCTAssertEqual(size, 0)
    }

    func testEvictsOldValuesAndDoesNotOverflow() {
        let cache = createCache(size: 2)
        cache.set(value: "a", for: "a")
        cache.set(value: "b", for: "b")
        cache.set(value: "c", for: "c")
        var value = cache.value(forKey: "a")
        XCTAssertNil(value)
        value = cache.value(forKey: "c")
        XCTAssertEqual(value, "c")
        let size = cache.totalSize
        XCTAssertEqual(size, 2)
    }

    func testDoesNotSetValueThatExceedsMaxByteSize() {
        let cache = createCache(size: 2)
        cache.set(value: "aaa", for: "aaa")
        let value = cache.value(forKey: "aaa")
        XCTAssertNil(value)
        let size = cache.totalSize
        XCTAssertEqual(size, 0)
    }

    func testRemovesOldValueForTheSameKey() {
        let cache = createCache(size: 2)
        cache.set(value: "a", for: "a")
        cache.set(value: "b", for: "a")
        let value = cache.value(forKey: "a")
        XCTAssertEqual(value, "b")
        let size = cache.totalSize
        XCTAssertEqual(size, 1)
    }

    func testRemovesAllData() {
        let cache = createCache()
        cache.set(value: "a", for: "a")
        cache.removeAll()
        let value = cache.value(forKey: "a")
        XCTAssertNil(value)
        let size = cache.totalSize
        XCTAssertEqual(size, 0)
    }
}
