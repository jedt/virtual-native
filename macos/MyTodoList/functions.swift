//
//  functions.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 12/31/23.
//

import Dispatch
import Foundation
import JavaScriptCore
import PureLayout
import Starscream
import Swifter

typealias SizeProps = [[String: (CGFloat, CGFloat)]]
typealias RectDictionary = [String: [String: CGFloat]]
typealias NSRectCreator = (RectDictionary) -> NSRect
typealias OriginSizePropsCalculator = (String, CGFloat, Int, CGFloat, [[String: CGFloat]], [[String: CGFloat]]) -> SizeProps

let context = JSContext()
var mainView = TNodeView()
var isConnected = false
let socketDelegate = WSClientSocket()
let server = HttpServer()
let localPath = "/Users/jedtiotuico/swift/vdom-native/macos/MyTodoList/main.bundle.js"
let urlString = "http://127.0.0.1:8080/download"

struct Props: Codable {
    let style: [String: CGFloat]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = (try? container.decode([String: CGFloat].self, forKey: .style)) ?? nil
    }
}

enum NodeChildren: Codable {
    case nodes([TNode]) // contains a list of objects
    case text(String)
    case nestedNodes([[TNode]]) // contains a list of lists

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
            return
        }
        if let nodes = try? container.decode([TNode].self) {
            self = .nodes(nodes)
            return
        }
        if let nestedNodes = try? container.decode([[TNode]].self) {
            self = .nestedNodes(nestedNodes)
            return
        }
        throw DecodingError.typeMismatch(
            NodeChildren.self,
            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode NodeChildren")
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .nodes(let nodes):
                try container.encode(nodes)
            case .text(let text):
                try container.encode(text)
            case .nestedNodes(let nestedNodes):
                try container.encode(nestedNodes)
        }
    }
}

struct TNode: Codable {
    let tagName: String
    let props: Props
    let children: NodeChildren

    enum CodingKeys: String, CodingKey {
        case tagName
        case props
        case children
    }
}

extension TNode {
    func getChildren() -> [TNode] {
        switch children {
            case .nodes(let children):
                // Direct list of children nodes
                return children

            case .nestedNodes(let nestedChildren):
                // Flatten the list of lists into a single list
                return nestedChildren.flatMap { $0 }

            case .text:
                // No TNode children in this case
                return []
        }
    }
}

func getPropsDictionary(_ node: TNode) -> [String: Any] {
    if node.props.style != nil {
        let style = node.props.style!
        let styleDict = style.reduce(into: [String: Any]()) { dict, style in
            dict[style.key] = style.value
        }
        return ["style": styleDict]
    } else {
        return [:]
    }
}

func setPropsDictionary(originalDict: [String: Any], key: String, value: Any) -> [String: Any] {
    // Creating a copy of the original dictionary
    var modifiedDict = originalDict

    // Set or update the value for the specified key
    modifiedDict[key] = value

    return modifiedDict
}

func getChildrenNodesFromTNode(_ node: TNode) -> [Any] {
    switch node.children {
        case .nodes(let children):
            // Direct list of children nodes
            return children

        case .nestedNodes(let nestedChildren):
            // Flatten the list of lists into a single list
            return nestedChildren.compactMap { node in
                node.map { dictionaryFromTNode($0) }
            }

        case .text:
            // No TNode children in this case
            return []
    }
}

func parseJSONStringToTree(_ jsonString: String) throws -> TNode {
    let jsonData = Data(jsonString.utf8)
    let decoder = JSONDecoder()

    let rootNode: TNode = try decoder.decode(TNode.self, from: jsonData)
    return rootNode
}

func printNodeWithDictionary(dictionary: [String: Any], indentLevel: Int = 0) {
    let indent = String(repeating: "  ", count: indentLevel) + (indentLevel > 0 ? "└─ " : "")

    if let tagName = dictionary["tagName"] as? String, let props = dictionary["props"] {
        let propsDescription = (props as? [String: Any])?.isEmpty ?? true ? "Props()" : "Props(\(props))"
        print("\(indent)tagName: \(tagName), props: \(propsDescription)")
    }

    if let childrenArrayContainer = dictionary["children"] as? [[[String: Any]]] {
        for childrenArray in childrenArrayContainer {
            for child in childrenArray {
                printNodeWithDictionary(dictionary: child, indentLevel: indentLevel + 1)
            }
        }
    }
}

func getChildrenArrayContainer(_ nodeChildren: NodeChildren) -> [[[String: Any]]] {
    switch nodeChildren {
        case .nodes(let nodes):
            return [nodes.map(dictionaryFromTNode)]
        case .text(let text):
            return [[["text": text]]]
        case .nestedNodes(let nestedNodes):
            // init:
            //    let arrayOfArrayOfDictionaries: [[[String: Any]]] = []
            // literals:
            //    let arrayOfArrayOfDictionaries: [[[String: Int]]] = [
            //        [
            //            ["key1": 1, "key2": 2],
            //            ["key3": 3, "key4": 4]
            //        ],
            //        [
            //            ["key5": 5],
            //            ["key6": 6, "key7": 7]
            //        ]
            //    ]

            return nestedNodes.map { innerList in
                innerList.map(dictionaryFromTNode)
            }
    }
}

func dictionaryFromTNode(_ node: TNode) -> [String: Any] {
    let tagName: String = node.tagName
    let props: [String: Any] = getPropsDictionary(node)

    return [
        "tagName": tagName,
        "props": props.isEmpty ? "Props()" : props,
        "children": getChildrenArrayContainer(node.children),
    ]
}

// func createLayoutizers() -> [String: Any] {
//    func createNSRect(dict: RectDictionary) -> NSRect {
//        // Extract the first value from the array of dictionaries for each key
//        let x = dict["origin"]?.first(where: { $0.keys.contains("left") })?["left"] ?? 0
//        let y = dict["origin"]?.first(where: { $0.keys.contains("top") })?["top"] ?? 0
//        let width = dict["size"]?.first(where: { $0.keys.contains("width") })?["width"] ?? 0
//        let height = dict["size"]?.first(where: { $0.keys.contains("height") })?["height"] ?? 0
//
//        return NSMakeRect(x, y, width, height)
//    }
//
//    return [
//        "createNSRect": createNSRect,
//        "calculateOriginSizeProps": calculateOriginSizeProps
//    ]
// }
//
// let layoutizers = createLayoutizers()
// let createNSRect = layoutizers["createNSRect"] as? NSRectCreator
func createNSRect(dict: RectDictionary) -> NSRect {
    // Directly access the values in the nested dictionaries
    let x = dict["origin"]?["left"] ?? 0
    let y = dict["origin"]?["top"] ?? 0
    let width = dict["size"]?["width"] ?? 0
    let height = dict["size"]?["height"] ?? 0

    return NSMakeRect(x, y, width, height)
}

func setPropsWithDict(props: [String: Any], withKey: String, withDict: [String: Any]) -> [String: Any] {
    return props.merging([withKey: withDict]) { _, new in new }
}

func setNodeWithProps(node: [String: Any], withProps: [String: Any]) -> [String: Any] {
    return node.merging(["props": withProps]) { _, new in new }
}

func updateDictionaryValue(withNode node: [String: Any], withValue value: Any, forKey key: String) -> [String: Any] {
    var copy = node
    copy.updateValue(value, forKey: key)
    return copy
}

func updateLayoutRectPropsDictionary(withProps props: [String: Any], withRectDictionary rectDict: RectDictionary) -> [String: Any] {
    var copy = props
    copy.updateValue(rectDict, forKey: "layout-rect")
    return copy
}

func createNode(withTagName: String, fromNode: [String: Any]) -> [String: Any] {
    return [
        "tagName": withTagName,
        "props": fromNode["props"]!,
    ]
}

func getChildrenCount(_ currentNode: [String: Any]) -> Int {
    guard let childrenArrayContainer = currentNode["children"] as? [[[String: Any]]] else {
        return 0
    }

    guard let childArrays = childrenArrayContainer.first else {
        return 0
    }

    guard let tagName: String = currentNode["tagName"] as? String else {
        return 0
    }

    return childArrays.count
}

func getTreeStringArray(_ node: TNode?, indent: String = "", isTail: Bool = true) -> [String] {
    guard let node = node else { return [] }

    var lines: [String] = []

    // current node
    let tailStr = isTail ? "└─" : "├─"
    lines.append("\(indent)\(tailStr) type: \(node.tagName), props: Props()")

    // Update indentation
    let childIndent = indent + (isTail ? "  " : "| ")

    switch node.children {
        case .text(let text):
            lines.append("\(childIndent)└─ text: \(text)")

        case .nodes(let children):
            for (index, child) in children.enumerated() {
                let childLines = getTreeStringArray(child, indent: childIndent, isTail: index == children.count - 1)
                lines.append(contentsOf: childLines)
            }

        case .nestedNodes(let nestedChildren):
            for (nestedIndex, nested) in nestedChildren.enumerated() {
                let lastNested = nestedIndex == nestedChildren.count - 1
                for (index, child) in nested.enumerated() {
                    let childLines = getTreeStringArray(child, indent: childIndent, isTail: lastNested && index == nested.count - 1)
                    lines.append(contentsOf: childLines)
                }
            }
    }

    return lines
}

func printTree(_ node: TNode?, indent: String = "", isTail: Bool = true) {
    let lines: [String] = getTreeStringArray(node, indent: indent, isTail: isTail)
    for line in lines {
        print(line)
    }
}

func buildViewHierarchy(from node: TNode?, superView: NSView) -> TNodeView? {
    guard let node = node else { return nil }

    let tnodeMap: [String: Any] = dictionaryFromTNode(node)
    mainView = TNodeView()
    mainView.tagName = "MainView"
    mainView.wantsLayer = true // Make the view layer-backed
    mainView.layer?.backgroundColor = NSColor.lightGray.cgColor
    mainView.layer?.borderWidth = 1
    mainView.layer?.borderColor = NSColor.black.cgColor
    superView.addSubview(mainView)
    createViews(from: tnodeMap)
    setupRootViewConstraints(view: mainView, in: superView)
    return mainView
}

private func createViews(from nodeDictionary: [String: Any], parentView: TNodeView? = nil) {
    guard let _: String = nodeDictionary["tagName"] as? String else {
        return
    }

    let currentParentView = parentView ?? mainView

    // Set view properties for currentParentView, e.g., background color, border, etc.
    if let propsDictionary: [String: Any] = nodeDictionary["props"] as? [String: Any] {
        // Set view props, e.g., background color, border, etc.
    }

    var previousSibling: TNodeView?
    let childrenCount = getChildrenCount(nodeDictionary)
    if let childrenArrayContainer = nodeDictionary["children"] as? [[[String: Any]]] {
        for childArray in childrenArrayContainer {
            for (index, childNodeDictionary) in childArray.enumerated() {
                if let childView = createChildView(from: childNodeDictionary) {
                    guard let tagName: String = childNodeDictionary["tagName"] as? String else {
                        continue
                    }
                    childView.tagName = tagName
                    currentParentView.addSubview(childView)

                    let isLastChild = index == (childrenCount - 1)

                    setupConstraints(
                        for: childView,
                        withParent: currentParentView,
                        previousSibling: previousSibling,
                        isLastChild: isLastChild,
                        siblingCount: childrenCount,
                        horizontalPadding: 10,
                        verticalPadding: 10
                    )

                    previousSibling = childView

                    createViews(from: childNodeDictionary, parentView: childView)
                }
            }
        }
    }
}

private func createChildView(from nodeDictionary: [String: Any]) -> TNodeView? {
    guard let _: String = nodeDictionary["tagName"] as? String else {
        return nil
    }

    let childView = TNodeView()
    childView.configureForAutoLayout()
    childView.wantsLayer = true
    childView.layer?.backgroundColor = NSColor.white.cgColor // Different color for testing
    childView.layer?.borderWidth = 1
    childView.layer?.borderColor = NSColor.black.cgColor
    childView.translatesAutoresizingMaskIntoConstraints = false

    return childView
}

private func setupRootViewConstraints(view: NSView, in superView: NSView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: superView.topAnchor),
        view.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
        view.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
        view.bottomAnchor.constraint(equalTo: superView.bottomAnchor),
    ])
}

private func setupConstraints(for childView: TNodeView,
                              withParent parentView: TNodeView,
                              previousSibling: TNodeView?,
                              isLastChild: Bool,
                              siblingCount: Int,
                              horizontalPadding: CGFloat = 0,
                              verticalPadding: CGFloat = 0)
{
    childView.translatesAutoresizingMaskIntoConstraints = false
    print("setupConstraints for \(String(describing: childView.tagName)) with \(String(describing: parentView.tagName))")

    childView.autoPinEdge(toSuperviewEdge: .left, withInset: horizontalPadding)
    childView.autoPinEdge(toSuperviewEdge: .right, withInset: horizontalPadding)

    if let previousSibling = previousSibling {
        childView.autoPinEdge(.top, to: .bottom, of: previousSibling, withOffset: verticalPadding)
    } else {
        if siblingCount > 1 {
            childView.autoPinEdge(toSuperviewEdge: .top, withInset: verticalPadding)
            childView.autoMatch(.height, to: .height, of: parentView, withMultiplier: 1 / CGFloat(siblingCount))
        }
    }

    if isLastChild {
        if siblingCount == 1 {
            childView.autoPinEdge(toSuperviewEdge: .top, withInset: verticalPadding)
            childView.autoPinEdge(toSuperviewEdge: .bottom, withInset: verticalPadding)
        } else if siblingCount > 1 {
            childView.autoPinEdge(toSuperviewEdge: .bottom, withInset: verticalPadding)
        }
    }
}

func evalJS(_ receivedString: String) -> String {
    let output_value: JSValue = (context?.evaluateScript(receivedString))!
    return output_value.toString() ?? "Error"
}

func READ(_ str: String) -> String {
    return str
}

func testCallback(withBuildID buildID : String) -> String {
    var resultString = ""
    let semaphore = DispatchSemaphore(value: 0)

    if let callbackFunction = context?.objectForKeyedSubscript("invokeExposedJsFn"), let result = callbackFunction.call(withArguments: [buildID]) {
        if let output = result.toString() {
            // this will return and return EVAL
            resultString = output
            semaphore.signal()
        }
    }

    while true {
        if semaphore.wait(timeout: .now() + 0.1) == .timedOut {
        } else {
            break // Semaphore has been signaled, exit the loop
        }
    }

    return resultString
}

func downloadBundle() -> String {
    var resultString = ""
    let semaphore = DispatchSemaphore(value: 0)
    downloadFile(from: urlString, to: localPath) { fileContents, error in
        if let error {
			resultString = "Download failed: \(error)"
            semaphore.signal()
        } else if let fileContents {
            context?.evaluateScript(fileContents)

            if let rootNodeFunction = context?.objectForKeyedSubscript("getRootNode"), let result = rootNodeFunction.call(withArguments: []) {
                if let output = result.toString() {
                    // this will return and return EVAL
                    resultString = output
                    semaphore.signal()
                }
            }
        } else {
            semaphore.signal()
            print("Downloaded file is empty or could not be read.")
        }
    }
    while true {
        if semaphore.wait(timeout: .now() + 0.1) == .timedOut {
        } else {
            break // Semaphore has been signaled, exit the loop
        }
    }
    
    return resultString
}

func EVAL(_ str: String) -> String {
	var resultString : [String] = []
    switch str {
        case "test-callback":
			resultString.append(downloadBundle())
			resultString.append(testCallback(withBuildID: "app.3.onPress"))
			resultString.append(testCallback(withBuildID: "app.4.onPress"))
        case "start":
            NotificationCenter.default.post(name: .createWindow, object: nil)
        case "fetch":
            socketDelegate.connectToBundler()
        case "download":
			resultString.append(downloadBundle())
            NotificationCenter.default.post(name: .refreshWindow, object: nil)
        case "disconnect":
            break
        default:
            break
    }
	return resultString.joined(separator: "\n")
}

func PRINT(_ exp: String) -> String {
    print(exp)
    return exp
}

func rep(str: String) -> String {
    PRINT(EVAL(READ(str)))
}

func connectToBundler() {
    socketDelegate.connectToBundler()
}

func readFileToString(from filePath: String) throws -> String? {
    do {
        let contents = try String(contentsOfFile: filePath)
        return contents
    } catch {
        throw NSError(domain: "Error reading file: \(error)", code: 0)
    }
}

func downloadFile(from urlString: String, to localPath: String, completion: @escaping (String?, Error?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }

    let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, _, error in
        if let tempLocalUrl, error == nil {
            let destinationUrl = URL(fileURLWithPath: localPath)

            do {
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.removeItem(at: destinationUrl)
                }

                try FileManager.default.moveItem(at: tempLocalUrl, to: destinationUrl)
                if let fileContents = try readFileToString(from: localPath) {
                    completion(fileContents, nil)
                } else {
                    print("Failed to read the file.")
                }
            } catch {
                completion(nil, error)
            }
        } else {
            completion(nil, error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
        }
    }

    task.resume()
}

func startServer() {
    do {
        server.listenAddressIPv4 = "127.0.0.1"
        server["/"] = { .ok(.htmlBody("You asked for \($0)")) }

        server["/websocket"] = websocket(
            text: { session, text in
                session.writeText(rep(str: text))
            },
            connected: { session in
                session.writeText("you are connected")
            })

        try server.start(8889, forceIPv4: true)
        print("started listening on 8889")
    } catch {
        print("server error")
    }
}
