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

var mainView: TNodeView?
var isConnected = false
var socketDelegate: WSClientSocket?
var server: HttpServer?
let localPath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("main.bundle.js")
    .path

let urlString = "http://127.0.0.1:8080/download"

extension JSContext {
    subscript(key: String) -> Any {
        get {
            return self.objectForKeyedSubscript(key) as Any
        }
        set{
            self.setObject(newValue, forKeyedSubscript: key as NSCopying & NSObjectProtocol)
        }
    }
}

@objc protocol JSConsoleExports: JSExport {
    static func log(_ msg: String)
}

class JSConsole: NSObject, JSConsoleExports {
    class func log(_ msg: String) {
        print(msg)
    }
}

class JSPromise: NSObject {
    enum JSPromiseResult {
        case success(Any)
        case failure(Any)
    }
    private var result: JSPromiseResult? {
        didSet {result.map(report)}
    }
    private var callbacks: [(JSPromiseResult) -> Void] = []
    func observe(using callback: @escaping (JSPromiseResult) -> Void) {
        if let result = result {
            return callback(result)
        }
        
        callbacks.append(callback)
    }
    
    private func report(result: JSPromiseResult) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
    
    convenience init(executor: @escaping (@escaping(Any)->Void, @escaping(Any)->Void) -> Void) {
        self.init()
        
        executor {[weak self] resolve in
            self?.result = .success(resolve)
        } _: {[weak self] reject in
            self?.result = .failure(reject)
        }
    }
    
    override init() {
    }
}

@objc protocol JSPromiseExports: JSExport {
    func then(_ resolve: JSValue) -> JSPromise
    func `catch`(_ reject: JSValue) -> JSPromise
}

extension JSPromise: JSPromiseExports {
    func then(_ block: JSValue) -> JSPromise {
        let weakBlock = JSManagedValue(value: block, andOwner: self)
        
        let promise = JSPromise()
        observe { result in
            switch result {
            case .success(let value):
                let next = weakBlock?.value.call(withArguments: [value]) as Any
                promise.result = .success(next)
            case .failure(let error):
                promise.result = .failure(error)
            }
        }
        
        return promise
    }
    
    func `catch`(_ block: JSValue) -> JSPromise {
        let weakBlock = JSManagedValue(value: block, andOwner: self)
        
        let promise = JSPromise()
        observe { result in
            switch result {
            case .success(let value):
                promise.result = .success(value)
            case .failure(let error):
                let next = weakBlock?.value.call(withArguments: [error]) as Any
                promise.result = .failure(next)
            }
        }
        
        return promise
    }
}

extension JSContext {
    static var plus:JSContext? {
        let jsMachine = JSVirtualMachine()
        guard let jsContext = JSContext(virtualMachine: jsMachine) else {
            return nil
        }
        
        jsContext.evaluateScript("""
            Error.prototype.isError = () => {return true}
        """)
        jsContext["console"] = JSConsole.self
        jsContext["Promise"] = JSPromise.self
        
        let fetch:@convention(block) (String) -> JSPromise = { link in
            return JSPromise{ resolve, reject in
                if let url = URL(string: link) {
                    URLSession.shared.dataTask(with: url){ (data, response, error) in
                        if let error = error {
                            reject(error.localizedDescription)
                        } else if
                            let data = data,
                            let string = String(data: data, encoding: String.Encoding.utf8) {
                            reject(string)
                        } else {
                            reject("\(url) is empty")
                        }
                    }.resume()
                } else {
                    reject("\(link) is not url")
                }
            }
        }
        
        jsContext["fetch"] = unsafeBitCast(fetch, to: JSValue.self)
        
        return jsContext
    }
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
            return nestedNodes.map { innerList in
                innerList.map(dictionaryFromTNode)
            }
    }
}

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

func propsToString(_ props: Props) -> String {
    var propsArray = [String]()

    if let style = props.style {
        let styleStr = style.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        propsArray.append("style: [\(styleStr)]")
    }

    if let onPress = props.onPress {
        propsArray.append("onPress: \(onPress)")
    }

    if let id = props.id {
        propsArray.append("id: \(id)")
    }

    if let bridgeID = props.bridgeID {
        propsArray.append("bridgeID: \(bridgeID)")
    }

    return propsArray.isEmpty ? "None" : propsArray.joined(separator: ", ")
}

func getTreeStringArray(_ node: TNode?, indent: String = "", isTail: Bool = true) -> [String] {
    guard let node = node else { return [] }

    var lines: [String] = []

    // Convert props to a string representation
    let propsString = propsToString(node.props)

    // current node
    let tailStr = isTail ? "└─" : "├─"
    lines.append("\(indent)\(tailStr) type: \(node.tagName), props: \(propsString)")

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
    mainView = TNodeView()
    guard let mainView = mainView else {
        return nil
    }

    let tnodeMap: [String: Any] = dictionaryFromTNode(node)

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

private func createViews(from nodeDictionary: [String: Any], parentView: TNodeView? = nil) {
    guard let tagName: String = nodeDictionary["tagName"] as? String else {
        return
    }

    if tagName == "NSButton" {
        if let childButton = createButton(from: nodeDictionary) {
            parentView?.addSubview(childButton)
        }
    }

    let currentParentView = parentView ?? mainView

    guard let currentParentView = currentParentView else {
        return
    }

    // Set view properties for currentParentView, e.g., background color, border, etc.
    if let propsDictionary: [String: Any] = nodeDictionary["props"] as? [String: Any] {
        // Set view props, e.g., background color, border, etc.
    }

    var previousSibling: TNodeView?
    let childrenCount = getChildrenCount(nodeDictionary)
    if let childrenArrayContainer = nodeDictionary["children"] as? [[[String: Any]]] {
        for childArray in childrenArrayContainer {
            for (index, childNodeDictionary) in childArray.enumerated() {
                if tagName == "NSButton" {
                    if let childButton = createButton(from: childNodeDictionary) {
                        currentParentView.addSubview(childButton)

//                           // Set up constraints for the button
//                           setupConstraints(
//                               for: childButton,
//                               withParent: currentParentView,
//                               previousSibling: previousSibling,
//                               isLastChild: index == (childrenCount - 1),
//                               siblingCount: childrenCount,
//                               horizontalPadding: 10,
//                               verticalPadding: 10
//                           )

                        // previousSibling = childButton
                    }
                } else {
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

private func createButton(from nodeDictionary: [String: Any]) -> NSButton? {
    guard let _: String = nodeDictionary["tagName"] as? String else {
        return nil
    }
    let button = BrigedComponentClass()
    button.translatesAutoresizingMaskIntoConstraints = false

    if let props: [String: Any] = nodeDictionary["props"] as? [String: Any] {
        if let bridgeID: String = props["bridgeID"] as? String {
            button.bridgeID = bridgeID
        }
    }

    return button
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

func evalJS(_ receivedString: String) -> String {
    let context = JSContext()
    let output_value: JSValue = (context?.evaluateScript(receivedString))!
    return output_value.toString() ?? "Error"
}

func READ(_ str: String) -> String {
    return str
}

func invokeJsAsync(withBridgeID bridgeID: String) -> String {
    let context = JSContext()
    var resultString = ""
    let semaphore = DispatchSemaphore(value: 0)

    if let callbackFunction = context?.objectForKeyedSubscript("invokeExposedJsFn"), let result = callbackFunction.call(withArguments: [bridgeID]) {
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

func testCallback(withBuildID buildID: String) throws -> String {
    guard let context = JSContext.plus else {
        fatalError("Could not create JSContext")
    }
    var resultString = ""
    let semaphore = DispatchSemaphore(value: 0)
    guard let fileContents = try readFileToString(from: localPath) else {
        return "error"
    }

    context.evaluateScript(fileContents)
    if let rootNodeFunction = context.objectForKeyedSubscript("getRootNode"), let _ = rootNodeFunction.call(withArguments: []) {
        if let callbackFunction = context.objectForKeyedSubscript("invokeExposedJsFn"), let result = callbackFunction.call(withArguments: [buildID]) {
            if let output = result.toString() {
                // this will return and return EVAL
                resultString = output
                semaphore.signal()
            }
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
    let context = JSContext()
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
    do {
        var resultString: [String] = []
        switch str {
            case "test-async":
                guard let context = JSContext.plus else {
                        fatalError("Could not create JSContext")
                    }

                context.evaluateScript("""
                    const asyncCallback2 = (async function () {
                        return new Promise((resolve, reject) => {
                            console.log("fetching..");
                            fetch("https://jsonplaceholder.typicode.com/todos/1")
                                .then((data) => {
                                    console.log("done");
                                    resolve(data);
                                })
                                .catch((e) => reject(e));
                        });
                    })();
                """)
                if let jsFunction = context.objectForKeyedSubscript("asyncCallback2"), let result = jsFunction.call(withArguments: []) {
                    if let output = result.toString() {
                        // this will return and return EVAL
                        resultString.append(output)
                    }
                }
            case "test-callback":
                resultString.append(try testCallback(withBuildID: "app.3.onPress"))
                resultString.append(try testCallback(withBuildID: "app.4.onPress"))
            case "start":
                NotificationCenter.default.post(name: .createWindow, object: nil)
            case "fetch":
                socketDelegate?.connectToBundler()
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
    catch {
        return "error"
    }
    
}

func PRINT(_ exp: String) -> String {
    print(exp)
    return exp
}

func rep(str: String) -> String {
    PRINT(EVAL(READ(str)))
}

func connectToBundler() {
    socketDelegate?.connectToBundler()
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
        socketDelegate = WSClientSocket()
        server = HttpServer()
        guard let server = server else {
            return
        }

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
