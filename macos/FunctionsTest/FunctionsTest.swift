import AppKit
import Nimble
import XCTest

final class FunctionsTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDictionaryFromTNodeProps_ParseJSONStringToTree() throws {
        let jsonString = #"""
        {
            "tagName": "View",
            "props": {},
            "children": [
                {
                    "tagName": "NSButton",
                    "props":{
                        "onPress":"function(){return Math.PI}",
                        "id":4,
                        "bridgeID":"app.4.onPress"
                    },
                    "children": "Hello, world."
                }
            ]
        }
        """#

        let parsed = try parseJSONStringToTree(jsonString)
        // Check if childNode is correctly parsed
        let childNode: TNode? = parsed.getChildren().first
        // Check if onPress is not nil and print it
        if let props = childNode?.props {
            expect(props.onPress).toNot(beNil(), description: "Text node should have 'onPress' prop")
            expect(props.bridgeID).to(equal("app.4.onPress"))
            expect(props.onPress).to(equal("function(){return Math.PI}"))
            expect(props.id).to(equal(4))
        } else {
            fail("Expected 'onPress' prop in child node, but found nil")
        }

        let dictionary: [String: Any] = dictionaryFromTNode(parsed)

        expect(dictionary["tagName"] as? String).to(equal("View"))
        expect(dictionary["props"] as? [String: Any]).to(beNil())

        let childrenArrayContainer: [[[String: Any]]] = getChildrenArrayContainer(parsed.children)
        let childrenContainer: [[String: Any]]? = childrenArrayContainer.first
        if let firstChild: [String: Any] = childrenContainer?.first {
            // Check the child node dictionary representation
            expect(firstChild["tagName"] as? String).to(equal("NSButton"))

            // Check the props of the child node
            if let childProps = firstChild["props"] as? [String: Any] {
                expect(childProps["onPress"] as? String).to(equal("function(){return Math.PI}"))
                expect(childProps["id"] as? Int).to(equal(4))
                expect(childProps["bridgeID"] as? String).to(equal("app.4.onPress"))
            } else {
                fail("Expected properties for the child node")
            }

            if firstChild["children"] is [[[String: Any]]] {
                // chatgpt fix this - the output below is "children": [[["text": "Hello, world."]]]]
                if let nestedChildrenArray = firstChild["children"] as? [[[String: Any]]],
                   let firstNestedChildren = nestedChildrenArray.first,
                   let firstNestedChild = firstNestedChildren.first,
                   let childText = firstNestedChild["text"] as? String
                {
                    expect(childText).to(equal("Hello, world."))
                } else {
                    fail("Expected children in the NSButton node to be 'Hello, world.'")
                }
            } else {
                fail("Expected children in the root node")
            }
        } else {
            fail("Expected children in the root node")
        }
    }

    func testChildrenArrayOfDictionariesParseJSONStringToTree() throws {
        let jsonString = #"""
        {"tagName": "View",
            "props": {},
            "children": [
                {
                    "tagName": "Text",
                    "props":{
                        "onPress":"function(){return Math.PI}",
                        "id":4,
                        "bridgeID":"app.4.onPress"
                    },
                    "children": "Hello, world."
                }
            ]}
        """#

        let parsed = try parseJSONStringToTree(jsonString)
        let dictionary = dictionaryFromTNode(parsed)
        let lines: [String] = getTreeStringArray(parsed)
        expect(lines.count).to(equal(3))
        expect(lines[0]).to(equal("└─ type: View, props: Props()"))
        expect(lines[1]).to(equal("  └─ type: Text, props: Props()"))
        expect(lines[2]).to(equal("    └─ text: Hello, world."))

        expect(parsed.tagName).to(equal("View"))
        let childrenArrayContainer: [[[String: Any]]] = getChildrenArrayContainer(parsed.children)
        expect(childrenArrayContainer.count).to(equal(1))
        let childrenContainer: [[String: Any]] = childrenArrayContainer[0]
        let firstChildDictionary: [String: Any] = childrenContainer.first!
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
        let dictionary = dictionaryFromTNode(parsed)
        expect(dictionary["tagName"] as? String).to(equal("View"))
        let childrenArrayContainer: [[[String: Any]]] = getChildrenArrayContainer(parsed.children)
        let childrenContainer: [[String: Any]] = childrenArrayContainer[0]
        let firstChildDictionary: [String: Any] = childrenContainer.first!
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
        let childrenArrayContainer: [[[String: Any]]] = getChildrenArrayContainer(parsed.children)
        expect(childrenArrayContainer.count).to(equal(2))
        let firstChildContainer: [[String: Any]] = childrenArrayContainer[0]
        expect(firstChildContainer.count).to(equal(1))
        let firstChildContainerFirstDictionary: [String: Any] = firstChildContainer[0] as [String: Any]
        expect(firstChildContainerFirstDictionary["tagName"] as? String).to(equal("Text"))
        // expect(firstChildDictionary["children"] as? [[[String: String]]]).to(equal([[["text": "Hello, world."]]]))
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

    func testSimpleNodeDictionary() throws {
        let jsonString = #"""
        {
            "tagName": "View",
            "props": {},
            "children": [
                {
                    "tagName": "Header",
                    "props": {"style": {"color": "blue"}},
                    "children": "Header Text"
                },
                {
                    "tagName": "Content",
                    "props": {},
                    "children": [
                        {
                            "tagName": "Text",
                            "props": {},
                            "children": "Content Text 1"
                        },
                        {
                            "tagName": "Text",
                            "props": {},
                            "children": "Content Text 2"
                        }
                    ]
                }
            ]
        }
        """#
        let parsed = try parseJSONStringToTree(jsonString)
        let tnodeMap: [String: Any]? = dictionaryFromTNode(parsed)
        expect(tnodeMap).toNot(beNil())

        // Test the tagName
        expect(tnodeMap?["tagName"] as? String).to(equal("View"))

        // Test the children
        let lines: [String] = getTreeStringArray(parsed)
        expect(lines[0]).to(equal("└─ type: View, props: Props()"))
        expect(lines[1]).to(equal("  ├─ type: Header, props: Props()"))
        expect(lines[2]).to(equal("  | └─ text: Header Text"))
        expect(lines[3]).to(equal("  └─ type: Content, props: Props()"))
        expect(lines[4]).to(equal("    ├─ type: Text, props: Props()"))
        expect(lines[5]).to(equal("    | └─ text: Content Text 1"))
        expect(lines[6]).to(equal("    └─ type: Text, props: Props()"))
        expect(lines[7]).to(equal("      └─ text: Content Text 2"))
    }

    func testTwoChildren() throws {
        let jsonString = #"""
        {
            "tagName":"body",
            "props":{},
            "children":[[
                    {
                        "tagName":"div",
                        "props":{},
                        "children":[{
                            "tagName":"View",
                                "props":{},
                                "children":[{
                                    "tagName":"Text",
                                    "props":{},
                                    "children":"Hello, "
                                }]
                        }]
                    },
                    {
                        "tagName":"div",
                        "props":{},
                        "children":[{
                            "tagName":"View",
                            "props":{},
                            "children":[{
                                "tagName":"Text",
                                "props":{},
                                "children":"world!!"
                            }]}]
            }]]
        }
        """#
        let parsed = try parseJSONStringToTree(jsonString)
        let lines: [String] = getTreeStringArray(parsed)
        printTree(parsed)
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
        {
            "tagName":"body",
            "props":{},
            "children":[[
                {
                    "tagName":"div",
                    "props":{},
                    "children":[{
                        "tagName":"View",
                        "props":{},
                        "children":[{
                            "tagName":"Text",
                            "props":{},
                            "children":"Hello, "
                        }]
                    }]},
                {
                    "tagName":"div",
                    "props":{},
                    "children":[{
                        "tagName":"View",
                        "props":{},
                        "children":[{
                            "tagName":"Text",
                            "props":{},
                            "children":"world!!"
                        }]
                    }]
                },
                {
                    "tagName":"div",
                    "props":{},
                    "children":[{
                        "tagName":"div",
                        "props":{},
                        "children":[[
                            {
                                "tagName":"div",
                                "props":{},
                                "children":[{
                                    "tagName":"Text",
                                    "props":{},
                                    "children":"foo"
                                }]},
                            {
                                "tagName":"div",
                                "props":{},
                                "children":[{
                                    "tagName":"Text",
                                    "props":{},
                                    "children":"bar"
                                }]
                            }
                        ]]
                    }]
                }
            ]]
        }
        """#

        let parsed = try parseJSONStringToTree(jsonString)
        let lines: [String] = getTreeStringArray(parsed)
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

    func testWithCallback() throws {
        let jsonString = #"""
        {
            "tagName":"bodyOfTwo",
            "children":[[
            {
                "tagName":"divTargetLeft",
                "children":[{
                    "tagName":"View",
                    "children":[{
                        "tagName":"Text",
                        "props":{},
                            "children":"TargetLeft"
                    }],
                    "props":{
                        "id":1
                    }
                }],
                "props":{"id":2}
            },
            {
                "tagName":"divTarget",
                "children":[{
                    "tagName":"View",
                    "children":[[
                        {
                            "tagName":"touchable",
                            "children":[],
                            "props":{
                                "onPress":"function(){return\"## bar ##\"}","id":3,
                                "bridgeID":"app.3.onPress"}
                        },
                        {
                            "tagName":"touchable",
                            "children":[],
                            "props":{
                                "onPress":"function(){return Math.PI}",
                                "id":4,
                                "bridgeID":"app.4.onPress"
                            }
                        },
                        {
                            "tagName":"View",
                            "children":[{
                                "tagName":"Text",
                                "props":{},
                                "children":"Sibling one"
                            }],
                            "props":{"id":5}
                        }
                    ]],
                    "props":{"id":6}
                }],
                "props":{"id":7}
            },
            {
                "tagName":"divTargetRight",
                "children":[{
                    "tagName":"View",
                    "children":[{
                        "tagName":"Text",
                        "props":{},
                        "children":"TargetRight"
                    }],
                    "props":{"id":8}
                }],
                "props":{"id":9}
            }
            ]],
            "props":{"id":10}
        }
        """#

        let parsed = try parseJSONStringToTree(jsonString)
        let lines: [String] = getTreeStringArray(parsed)
        printTree(parsed)
    }
}
