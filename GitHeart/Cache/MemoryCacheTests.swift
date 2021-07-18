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

private func cache(size: Int = 20) -> MemoryCache<String, String> {
    return MemoryCache(maxByteSize: size)
}

class MemoryCacheTests: XCTestCase {
    func testSetsAndGetsValue() throws {
        let c = cache()
        c.set(value: "a", for: "b")
        XCTAssertEqual(c.value(forKey: "b"), "a")
    }

    func testTotalSizeChanges() {
        let c = cache()
        c.set(value: "a", for: "a")
        c.set(value: "bb", for: "bb")
        c.set(value: "ccc", for: "ccc")
        XCTAssertEqual(c.totalSize, 6)
        c.set(value: nil, for: "ccc")
        XCTAssertEqual(c.totalSize, 3)
        c.removeAll()
        XCTAssertEqual(c.totalSize, 0)
    }

    func testEvictsOldValuesAndDoesntOverflow() {
        let c = cache(size: 2)
        c.set(value: "a", for: "a")
        c.set(value: "b", for: "b")
        c.set(value: "c", for: "c")
        XCTAssertNil(c.value(forKey: "a"))
        XCTAssertEqual(c.value(forKey: "c"), "c")
        XCTAssertEqual(c.totalSize, 2)
    }

    func testDoesntSetBigValue() {
        let c = cache(size: 2)
        c.set(value: "aaa", for: "aaa")
        XCTAssertNil(c.value(forKey: "aaa"))
        XCTAssertEqual(c.totalSize, 0)
    }

    func testRemovesOldValueForTheSameKey() {
        let c = cache(size: 2)
        c.set(value: "a", for: "a")
        c.set(value: "b", for: "a")
        XCTAssertEqual(c.value(forKey: "a"), "b")
        XCTAssertEqual(c.totalSize, 1)
    }

    func testFreeMemoryRemovesAllData() {
        let c = cache()
        c.set(value: "a", for: "a")
        c.freeMemory()
        XCTAssertNil(c.value(forKey: "a"))
        XCTAssertEqual(c.totalSize, 0)
    }
}
