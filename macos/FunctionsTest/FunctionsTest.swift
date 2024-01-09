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

// Extract specific functions from the factory


final class FunctionsTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testUpdateLayoutRectPropsDictionary() throws {
        let layoutRectDictionary: RectDictionary = [
            "origin": [
                "left": 10.0,
                "top": 20.0
            ],
            "size": [
                "width": 100.0,
                "height": 200.0
            ]
        ]
        let props : [String: Any] = ["layout-rect": layoutRectDictionary]
        let copy = updateLayoutRectPropsDictionary(withProps: props, withRectDictionary: [
            "origin": [
                "left": 10.0,
                "top": 20.0
            ],
            "size": [
                "width": 101.0,
                "height": 201.0
            ]
        ])
        
        let actualRect : RectDictionary = copy["layout-rect"] as! RectDictionary
        expect(actualRect["size"]?["width"]).to(equal(101.0))
        expect(actualRect["size"]?["height"]).to(equal(201.0))
    }
    
    func testUpdateDictionaryValue() {
        let layoutRectDictionary: RectDictionary = [
            "origin": [
                "left": 10.0,
                "top": 20.0
            ],
            "size": [
                "width": 100.0,
                "height": 200.0
            ]
        ]
        let props : [String: Any] = ["layout-rect": layoutRectDictionary]
        let node = [
            "tagName": "View",
            "props": props,
            "children": [:]
        ] as [String : Any]
        let updatedProps = updateLayoutRectPropsDictionary(withProps: props, withRectDictionary: [
            "origin": [
                "left": 10.0,
                "top": 20.0
            ],
            "size": [
                "width": 101.0,
                "height": 201.0
            ]
        ])
        let copy = updateDictionaryValue(withNode: node, withValue: updatedProps, forKey: "props")
        let copyProps = copy["props"] as! [String: Any]
        let actualRect : RectDictionary = copyProps["layout-rect"] as! RectDictionary
        expect(actualRect["size"]?["width"]).to(equal(101.0))
        expect(actualRect["size"]?["height"]).to(equal(201.0))
    }
    func testCreateRect() throws {
//        let layoutizers = createLayoutizers()
//        let createNSRect = layoutizers["createNSRect"] as? NSRectCreator
        let literalExampleRectDictionary: RectDictionary = [
            "origin": [
                "left": 10.0,
                "top": 20.0
            ],
            "size": [
                "width": 100.0,
                "height": 200.0
            ]
        ]

        let rect : NSRect = createNSRect(dict: literalExampleRectDictionary)
        expect(rect.origin.x).to(equal(10.0))
        expect(rect.origin.y).to(equal(20.0))
        expect(rect.width).to(equal(100.0))
        expect(rect.height).to(equal(200.0))
    }

    func testChildrenArrayOfDictionariesParseJSONStringToTree() throws {
        let jsonString = #"""
        {"tagName": "View",
            "props": {},
            "children": [
                {
                    "tagName": "Text",
                    "props": {},
                    "children": "Hello, world."
                }
            ]}
        """#
        let parsed = try parseJSONStringToTree(jsonString)
        let lines: [String] = getTreeStringArray(parsed)
        expect(lines.count).to(equal(3))
        expect(lines[0]).to(equal("└─ type: View, props: Props()"))
        expect(lines[1]).to(equal("  └─ type: Text, props: Props()"))
        expect(lines[2]).to(equal("    └─ text: Hello, world."))

        expect(parsed.tagName).to(equal("View"))
        let childrenArrayContainer: [[[String: Any]]] = getChildrenArrayContainer(parsed.children)
        expect(childrenArrayContainer.count).to(equal(1))
        let childrenContainer: [[String: Any]] = childrenArrayContainer[0]
        let firstChildDictionary : [String: Any] = childrenContainer.first!
        expect(firstChildDictionary["tagName"] as? String).to(equal("Text"))
        expect(firstChildDictionary["children"] as? [[[String: String]]]).to(equal([[["text": "Hello, world."]]]))
    }
    func testDictionaryFromTNodeParseJSONStringToTree() throws {
        let jsonString = #"""
        {"tagName": "View",
            "props": {},
            "children": [
                {
                    "tagName": "Text",
                    "props": {},
                    "children": "Hello, world."
                }
            ]}
        """#
        let parsed = try parseJSONStringToTree(jsonString)
        let dictionary = dictionaryFromTNode(parsed);
        expect(dictionary["tagName"] as? String).to(equal("View"))
        let childrenArrayContainer: [[[String: Any]]] = getChildrenArrayContainer(parsed.children)
        let childrenContainer: [[String: Any]] = childrenArrayContainer[0]
        let firstChildDictionary : [String: Any] = childrenContainer.first!
        expect(firstChildDictionary["tagName"] as? String).to(equal("Text"))
        expect(firstChildDictionary["children"] as? [[[String: String]]]).to(equal([[["text": "Hello, world."]]]))
    }

    func testGetChildrenRepresentationArrayOfArraysParseJSONStringToTree() throws {
        let jsonString = #"""
        {"tagName": "View",
            "props": {},
            "children": [
                [
                    {
                        "tagName": "Text",
                        "props": {},
                        "children": "Hello, world."
                    }
                ],
                [
                    {
                        "tagName": "Text",
                        "props": {},
                        "children": "Array of Array Child A"
                    },
                    {
                        "tagName": "Text",
                        "props": {},
                        "children": "Array of Array Child B"
                    },
                ]
            ]
        }
        """#

        let parsed = try parseJSONStringToTree(jsonString)
        printTree(parsed)
        let lines: [String] = getTreeStringArray(parsed)
        expect(lines.count).to(equal(7))
        expect(lines[0]).to(equal("└─ type: View, props: Props()"))
        expect(lines[1]).to(equal("  ├─ type: Text, props: Props()"))
        expect(lines[2]).to(equal("  | └─ text: Hello, world."))
        expect(lines[3]).to(equal("  ├─ type: Text, props: Props()"))
        expect(lines[4]).to(equal("  | └─ text: Array of Array Child A"))
        expect(lines[5]).to(equal("  └─ type: Text, props: Props()"))
        expect(lines[6]).to(equal("    └─ text: Array of Array Child B"))
        expect(parsed.tagName).to(equal("View"))
        // let arrayOfArrayOfDictionaries: [[[String: Int]]] = [
        //    [
        //        [
        //          "tagName": "Text",
        //          "props": {},
        //          "children": [text: "Array of Array Child A"]
        //        ]
        //    ],
        //    [
        //        [
        //          "tagName": "Text",
        //          "props": {},
        //          "children": [text: "Array of Array Child A."]
        //        ],
        //        [
        //          "tagName": "Text",
        //          "props": {},
        //          "children": [text: "Array of Array Child B."]
        //        ]
        //    ]
        // ]
        let childrenArrayContainer: [[[String: Any]]] = getChildrenArrayContainer(parsed.children)
        expect(childrenArrayContainer.count).to(equal(2))
        let firstChildContainer: [[String: Any]] = childrenArrayContainer[0]
        expect(firstChildContainer.count).to(equal(1))
        let firstChildContainerFirstDictionary: [String: Any] = firstChildContainer[0] as [String: Any]
        expect(firstChildContainerFirstDictionary["tagName"] as? String).to(equal("Text"))
        //expect(firstChildDictionary["children"] as? [[[String: String]]]).to(equal([[["text": "Hello, world."]]]))
        expect(firstChildContainerFirstDictionary["children"] as? [[[String: String]]]).to(equal([[["text": "Hello, world."]]]))
        let secondChildContainer: [[String: Any]] = childrenArrayContainer[1]
        expect(secondChildContainer.count).to(equal(2))
        let secondChildContainerFirstDictionary: [String: Any] = secondChildContainer[0] as [String: Any]
        expect(secondChildContainerFirstDictionary["tagName"] as? String).to(equal("Text"))
        expect(secondChildContainerFirstDictionary["children"] as? [[[String: String]]]).to(equal([[["text": "Array of Array Child A"]]]))
        let secondChildContainerSecondDictionary: [String: Any] = secondChildContainer[1] as [String: Any]
        expect(secondChildContainerSecondDictionary["tagName"] as? String).to(equal("Text"))
        expect(secondChildContainerSecondDictionary["children"] as? [[[String: String]]]).to(equal([[["text": "Array of Array Child B"]]]))
    }

    func testCalculateLayoutFromPrintedOutput() throws {
        let jsonString = #"""
        {
            "tagName": "body",
            "props": {},
            "children": [
                {
                    "tagName": "divTargetLeft",
                    "props": {},
                    "children": [
                        {
                            "tagName": "View",
                            "props": {},
                            "children": [
                                {
                                    "tagName": "Text",
                                    "props": {},
                                    "children": "TargetLeft"
                                }
                            ]
                        }
                    ]
                },
                {
                    "tagName": "divTarget",
                    "props": {},
                    "children": [
                        {
                            "tagName": "View",
                            "props": {},
                            "children": [
                                {
                                    "tagName": "View",
                                    "props": {},
                                    "children": [
                                        {
                                            "tagName": "Text",
                                            "props": {},
                                            "children": "TargetChild"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                {
                    "tagName": "divTargetRight",
                    "props": {},
                    "children": [
                        {
                            "tagName": "View",
                            "props": {},
                            "children": [
                                {
                                    "tagName": "Text",
                                    "props": {},
                                    "children": "TargetRight"
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """#

        let parsed = try parseJSONStringToTree(jsonString)
        var tnodeMap: [String: Any] = dictionaryFromTNode(parsed)
        expect(tnodeMap["tagName"] as? String).to(equal("body"))
        
        //let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
        //let windowSize = (CGFloat(screenSize.width), CGFloat(screenSize.height))

//        let updatedTNodeMap = calculateLayout(withPadding: 10.0, toCurrentNode: tnodeMap, withParent: nil, withSiblingIndex: 0, withSiblingCount: 1);
        
//
//        calculateLayout(origin: (0, 0), size: windowSize, currentNode: &tnodeMap, parent: nil, siblingIndex: 0, siblingCount: 1)
//
//        // Assertions for the root node
//        expect(tnodeMap["width"] as? CGFloat).to(equal(windowSize.0))
//        expect(tnodeMap["height"] as? CGFloat).to(equal(windowSize.1))
//        expect(tnodeMap["left"] as? CGFloat).to(equal(0))
//        expect(tnodeMap["top"] as? CGFloat).to(equal(0))
//
//        let children = tnodeMap["children"] as? [[String: Any]]
//        expect(children!.count).to(equal(3))
//
//        let divTargetLeft = children![0]
//        expect(divTargetLeft["tagName"] as? String).to(equal("divTargetLeft"))
//
//        let divTarget = children![1]
//        expect(divTarget["tagName"] as? String).to(equal("divTarget"))
//
//        let divTargetRight = children![2]
//        expect(divTargetRight["tagName"] as? String).to(equal("divTargetRight"))
    }
//
//    func testSimpleNodeDictionary() throws {
//        let jsonString = #"""
//        {
//            "tagName": "View",
//            "props": {},
//            "children": [
//                {
//                    "tagName": "Header",
//                    "props": {"style": {"color": "blue"}},
//                    "children": "Header Text"
//                },
//                {
//                    "tagName": "Content",
//                    "props": {},
//                    "children": [
//                        {
//                            "tagName": "Text",
//                            "props": {},
//                            "children": "Content Text 1"
//                        },
//                        {
//                            "tagName": "Text",
//                            "props": {},
//                            "children": "Content Text 2"
//                        }
//                    ]
//                }
//            ]
//        }
//        """#
//        let parsed = try parseJSONStringToTree(jsonString)
//        let tnodeMap: [String: Any]? = dictionaryFromTNode(parsed)
//        expect(tnodeMap).toNot(beNil())
//
//        // Test the tagName
//        expect(tnodeMap?["tagName"] as? String).to(equal("View"))
//
//        // Test the props
//        expect(tnodeMap?["props"] as? [String: CGFloat]).to(equal([:]))
//
//        // Test the children
//        let children = tnodeMap?["children"] as? [[String: Any]]
//        expect(children!.count).to(equal(2))
//        let firstChild = children!.first
//        expect(firstChild!["tagName"] as? String).to(equal("Header"))
//        expect(firstChild!["props"] as? [String: [String: String]]).to(equal([:]))
//        let secondChild = children![1]
//        expect(secondChild["tagName"] as? String).to(equal("Content"))
//    }
//
//    func testTwoChildren() throws {
//        let jsonString = #"""
//        {"tagName":"body","props":{},"children":[[{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"Hello, "}]}]},{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"world!!"}]}]}]]}
//        """#
//        let parsed = try parseJSONStringToTree(jsonString)
//        let lines: [String] = getTreeStringArray(parsed)
//        printTree(parsed)
//        expect(lines[0]).to(equal("└─ type: body, props: Props()"))
//        expect(lines[1]).to(equal("  ├─ type: div, props: Props()"))
//        expect(lines[2]).to(equal("  | └─ type: View, props: Props()"))
//        expect(lines[3]).to(equal("  |   └─ type: Text, props: Props()"))
//        expect(lines[4]).to(equal("  |     └─ text: Hello, "))
//        expect(lines[5]).to(equal("  └─ type: div, props: Props()"))
//        expect(lines[6]).to(equal("    └─ type: View, props: Props()"))
//        expect(lines[7]).to(equal("      └─ type: Text, props: Props()"))
//        expect(lines[8]).to(equal("        └─ text: world!!"))
//    }
//
//    func testComplexNestedNode() throws {
//        let jsonString = #"""
//        {"tagName":"body","props":{},"children":[[{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"Hello, "}]}]},{"tagName":"div","props":{},"children":[{"tagName":"View","props":{},"children":[{"tagName":"Text","props":{},"children":"world!!"}]}]},{"tagName":"div","props":{},"children":[{"tagName":"div","props":{},"children":[[{"tagName":"div","props":{},"children":[{"tagName":"Text","props":{},"children":"foo"}]},{"tagName":"div","props":{},"children":[{"tagName":"Text","props":{},"children":"bar"}]}]]}]}]]}
//        """#
//
//        let parsed = try parseJSONStringToTree(jsonString)
//        let lines: [String] = getTreeStringArray(parsed)
//        expect(lines[0]).to(equal("└─ type: body, props: Props()"))
//        expect(lines[1]).to(equal("  ├─ type: div, props: Props()"))
//        expect(lines[2]).to(equal("  | └─ type: View, props: Props()"))
//        expect(lines[3]).to(equal("  |   └─ type: Text, props: Props()"))
//        expect(lines[4]).to(equal("  |     └─ text: Hello, "))
//        expect(lines[5]).to(equal("  ├─ type: div, props: Props()"))
//        expect(lines[6]).to(equal("  | └─ type: View, props: Props()"))
//        expect(lines[7]).to(equal("  |   └─ type: Text, props: Props()"))
//        expect(lines[8]).to(equal("  |     └─ text: world!!"))
//        expect(lines[9]).to(equal("  └─ type: div, props: Props()"))
//        expect(lines[10]).to(equal("    └─ type: div, props: Props()"))
//        expect(lines[11]).to(equal("      ├─ type: div, props: Props()"))
//        expect(lines[12]).to(equal("      | └─ type: Text, props: Props()"))
//        expect(lines[13]).to(equal("      |   └─ text: foo"))
//        expect(lines[14]).to(equal("      └─ type: div, props: Props()"))
//        expect(lines[15]).to(equal("        └─ type: Text, props: Props()"))
//        expect(lines[16]).to(equal("          └─ text: bar"))
//    }
}
