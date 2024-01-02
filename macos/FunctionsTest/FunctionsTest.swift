//
//  FunctionsTest.swift
//  FunctionsTest
//
//  Created by Jed Tiotuico on 1/1/24.
//
import AppKit
import Cocoa
import CoreText
import JavaScriptCore
import Nimble
import Starscream
import XCTest

final class FunctionsTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExampleSimpleNode() throws {
        let jsonString = #"""
        {"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"Hello, world."}]}
        """#

        let parsed = parseJSONStringToTree(jsonString)
        let lines : [String] = getTreeStringArray(parsed);
        expect(lines[0]).to(equal("└─ type: View, props: Props()"))
        expect(lines[1]).to(equal("  └─ type: Text, props: Props()"))
        expect(lines[2]).to(equal("    └─ text: Hello, world."))
    }
    
    func testTwoChildren() {
        let jsonString = #"""
{"tagName":"body","props":{},"children":[[{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"Hello, "}]}]},{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"world!!"}]}]}]]}
"""#
        let parsed = parseJSONStringToTree(jsonString)
        let lines : [String] = getTreeStringArray(parsed);
        expect(lines[0]).to(equal("└─ type: body, props: Props()"))
        expect(lines[1]).to(equal("  ├─ type: div, props: Props()"))
        expect(lines[2]).to(equal("  | └─ type: View, props: Props()"))
        expect(lines[3]).to(equal("  |   └─ type: Text, props: Props()"))
        expect(lines[4]).to(equal("  |     └─ text: Hello, "))
        expect(lines[5]).to(equal("  └─ type: div, props: Props()"))
        expect(lines[6]).to(equal("    └─ type: View, props: Props()"))
        expect(lines[7]).to(equal("      └─ type: Text, props: Props()"))
        expect(lines[8]).to(equal("        └─ text: world!!"))
    }

    func testComplexNestedNode() throws {
        let jsonString = #"""
        {"tagName":"body","props":{},"children":[[{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"Hello, "}]}]},{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"world!!"}]}]},{"tagName":"div","props":{},"children":[{"tagName":"div","props":{},"children":[[{"tagName":"div","props":{},"children":[{"tagName":"Text","props":{},"children":"foo"}]},{"tagName":"div","props":{},"children":[{"tagName":"Text","props":{},"children":"bar"}]}]]}]}]]}
        """#
        
        let parsed = parseJSONStringToTree(jsonString)
        printTree(parsed)
        let lines : [String] = getTreeStringArray(parsed);
        expect(lines[0]).to(equal("└─ type: body, props: Props()"))
        expect(lines[1]).to(equal("  ├─ type: div, props: Props()"))
        expect(lines[2]).to(equal("  | └─ type: View, props: Props()"))
        expect(lines[3]).to(equal("  |   └─ type: Text, props: Props()"))
        expect(lines[4]).to(equal("  |     └─ text: Hello, "))
        expect(lines[5]).to(equal("  ├─ type: div, props: Props()"))
        expect(lines[6]).to(equal("  | └─ type: View, props: Props()"))
        expect(lines[7]).to(equal("  |   └─ type: Text, props: Props()"))
        expect(lines[8]).to(equal("  |     └─ text: world!!"))
        expect(lines[9]).to(equal("  └─ type: div, props: Props()"))
        expect(lines[10]).to(equal("    └─ type: div, props: Props()"))
        expect(lines[11]).to(equal("      ├─ type: div, props: Props()"))
        expect(lines[12]).to(equal("      | └─ type: Text, props: Props()"))
        expect(lines[13]).to(equal("      |   └─ text: foo"))
        expect(lines[14]).to(equal("      └─ type: div, props: Props()"))
        expect(lines[15]).to(equal("        └─ type: Text, props: Props()"))
        expect(lines[16]).to(equal("          └─ text: bar"))
    }
}
