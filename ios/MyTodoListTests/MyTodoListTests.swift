//
//  MyTodoListTests.swift
//  MyTodoListTests
//
//  Created by Jed Tiotuico on 12/3/23.
//

import XCTest

@testable import MyTodoList

final class MyTodoListTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testParseValidJson() {
        let jsonString = ""
        guard let tree = parseJSONStringToSimpleTree(jsonString) else {
            XCTFail("Failed to parse valid JSON")
            return
        }
        XCTAssertEqual(tree.t, "VirtualNode", "Incorrect node type")
    }
}
