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
        let jsonString = """
        {"t":"VirtualNode","tn":"DIV","p":{"id":"root"},"c":[]}
        """
        guard let tree = parseJSONStringToSimpleTree(jsonString) else {
            XCTFail("Failed to parse valid JSON")
            return
        }
        XCTAssertEqual(tree.t, "VirtualNode", "Incorrect node type")
        XCTAssertEqual(tree.tn, "DIV", "Incorrect tag name")
        XCTAssertEqual(tree.p?.id, "root", "Incorrect id in properties")
        XCTAssertTrue(tree.c?.isEmpty ?? false, "Children array should be empty")
    }


    func testParseValidJsonWithChildren() {
        let jsonString = """
        {"t":"VirtualNode","tn":"DIV","p":{"id":"root"},"c":[{"t":"VirtualNode","tn":"SPAN","p":{"className":"child"},"c":[]}]}
        """
        guard let tree = parseJSONStringToSimpleTree(jsonString) else {
            XCTFail("Failed to parse valid JSON with children")
            return
        }
        XCTAssertEqual(tree.t, "VirtualNode", "Incorrect root node type")
        XCTAssertEqual(tree.tn, "DIV", "Incorrect root tag name")
        XCTAssertEqual(tree.p?.id, "root", "Incorrect root id in properties")
        XCTAssertNotNil(tree.c, "Children array should not be nil")
        XCTAssertEqual(tree.c?.count, 1, "There should be exactly one child node")
        XCTAssertEqual(tree.c?.first?.t, "VirtualNode", "Incorrect child node type")
        XCTAssertEqual(tree.c?.first?.tn, "SPAN", "Incorrect child tag name")
        XCTAssertEqual(tree.c?.first?.p?.className, "child", "Incorrect className in child properties")
        XCTAssertTrue(tree.c?.first?.c?.isEmpty ?? false, "Child's children array should be empty")
    }
    
    func testParseValidJsonLarge() {
        let jsonString = """
                 {"t":"VirtualNode","tn":"DIV","p":{"id":"root"},"c":[{"t":"VirtualNode","tn":"BODY","c":[{"t":"VirtualNode","tn":"DIV","p":{"id":"tree-div"},"c":[{"t":"VirtualNode","tn":"DIV","p":{"id":"some-id","className":"foo"},"c":[{"t":"VirtualNode","tn":"SPAN","c":[{"t":"VirtualTree","x":"span text"}]},{"t":"VirtualNode","tn":"INPUT","p":{"type":"text","value":{"value":"foo-tree","hook":{}}}}]}]},{"t":"VirtualNode","tn":"INPUT","p":{"type":"text","value":{"value":"bar","hook":{}}}}]}]}
                """
        guard let tree = parseJSONStringToSimpleTree(jsonString) else {
            XCTFail("Failed to parse valid JSON with children")
            return
        }
        
        // Example usage
        //printTree(tree)
        
        XCTAssertEqual(tree.t, "VirtualNode", "Incorrect root node type")
        XCTAssertEqual(tree.tn, "DIV", "Incorrect root tag name")
        XCTAssertEqual(tree.p?.id, "root", "Incorrect id in properties")
        XCTAssertEqual(tree.c?.count, 1, "There should be 1 child")
        let bodyNode = tree.c?.first
        XCTAssertEqual(bodyNode?.t, "VirtualNode", "Incorrect child node type")
        XCTAssertEqual(bodyNode?.tn, "BODY", "Incorrect child tag name")
        XCTAssertEqual(bodyNode?.c?.count, 2, "There should be 2 children")
        XCTAssertEqual(bodyNode?.c?.first?.t, "VirtualNode", "Incorrect child node type")
        XCTAssertEqual(bodyNode?.c?.first?.tn, "DIV", "Incorrect child tag name")
        let treeDiv = bodyNode?.c?.first
        
        XCTAssertEqual(treeDiv?.p?.id, "tree-div", "Incorrect id in properties")
        XCTAssertEqual(treeDiv?.c?.count, 1, "There should be 1 child")
        let someId = treeDiv?.c?.first

        XCTAssertEqual(someId?.p?.id, "some-id", "Incorrect id in properties")
        XCTAssertEqual(someId?.p?.className, "foo", "Incorrect className in properties")
        XCTAssertEqual(someId?.c?.count, 2, "There should be 2 children")
        
        let span = someId?.c?.first
        XCTAssertEqual(span?.t, "VirtualNode", "Incorrect child node type")
        let input = someId?.c?.last
        XCTAssertEqual(input?.t, "VirtualNode", "Incorrect child node type")
        
    }


}
