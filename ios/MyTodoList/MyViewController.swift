//
//  ViewController.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 11/30/23.
//

import AppKit
import JavaScriptCore
import Cocoa
import CoreText
import Starscream

class QuartzRootView: NSView {
    var drawNode : Any?
    //override func initWithFrame
    init() {
        let frameRect = NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 1200.0, height: 800.0))
        super.init(frame: frameRect)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    func calcWidth(_ fontSize: Int, _ textDisplay: String) -> CGFloat {
        let font = NSFont(name: "Helvetica", size: CGFloat(fontSize))
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: textDisplay, attributes: attributes as [NSAttributedString.Key : Any])
        let size = attributedString.size()
        return size.width
    }
    
    func calcBoundingBox(_ origin : CGPoint, _ fontSize: Int, _ textDisplay: String) -> NSRect {
        let width = calcWidth(fontSize, textDisplay)
        let height = CGFloat(fontSize)
        let boundingBox = NSRect(x: 0, y: origin.y, width: width, height: height)
        return boundingBox
    }
    
    func buildViewTree(from rootNode: TreeNode) -> [[String: Any]] {
        var viewFrames = [[String: Any]]()

        func buildTree(_ node: TreeNode, containerFrame: CGRect, depth: Int = 0) {
            let flexGrow = CGFloat(Double(node.p?.id ?? "1") ?? 1)
            let childrenFlexGrow = node.c?.map { _ in flexGrow } ?? [flexGrow]
            let spacing: CGFloat = 10

            let flexDirection = node.p?.flexDirection ?? "column"
            let rectPositions = calculateRectPositions(flexDirection: flexDirection, containerFrame: containerFrame, childrenFlexGrow: childrenFlexGrow, spacing: spacing)
            
            var opacity = 1.0 //initially the div is invisible
            var bgColor = "#FFFFFF"
            var textDisplay = ""
            var fontSize = 12
            
            if (node.tn == "DIV") {
                opacity = 0.0
                if (node.p?.backgroundColor != nil) {
                    bgColor = (node.p?.backgroundColor)!
                    opacity = 1.0
                }
            }
            else if (node.tn == "TEXT") {
                textDisplay = node.p?.text ?? ""
                fontSize = (node.p?.fontSize)!
            }
            
            for (index, rect) in rectPositions.enumerated() {
                var frameData: [String: Any]
                if (node.tn == "DIV") {
                    frameData = [
                        "id": node.p?.id ?? "",
                        "backgroundColor": bgColor,
                        "opacity": opacity,
                        "frame": rect,
                    ]
                }
                else {
                    let centerRect : CGPoint = CGPoint(x: rect.origin.x + rect.width/2, y: rect.origin.y + rect.height/2)
                    let boundingBox : NSRect = calcBoundingBox(centerRect, fontSize, textDisplay)
                    frameData = [
                        "id": node.p?.id ?? "",
                        "backgroundColor": bgColor,
                        "opacity": opacity,
                        "text": textDisplay,
                        "fontSize": fontSize,
                        "boundingBox": boundingBox,
                    ]
                }
                
                viewFrames.append(frameData)

                if let children = node.c, index < children.count {
                    buildTree(children[index], containerFrame: rect, depth: depth + 1)
                }
            }
        }

        buildTree(rootNode, containerFrame: self.frame)
        return viewFrames
    }
    
    func setDrawNodeAndRedraw(_ rootNode: TreeNode) {
        drawNode = rootNode
        self.needsDisplay = true
    }

    func drawQuartzBlackRomanText(_ context: CGContext, _ text: String, _ rect: NSRect) {
        context.saveGState()
        context.setFillColor(NSColor.black.cgColor)
        //context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)

        let attributedString = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: NSFont(name: "Helvetica", size: 16) as Any,
            NSAttributedString.Key.foregroundColor: NSColor.black
        ])
        
        let line = CTLineCreateWithAttributedString(attributedString as CFAttributedString)
        
        let centerPos = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
        context.textPosition = centerPos
        CTLineDraw(line, context)

        context.restoreGState()
    }

    func doSimpleRect(_ context: CGContext, _ rootNode: TreeNode) {
        if let rectPositions = buildViewTree(from: rootNode) as [[String: Any]]? {
            for rectPosition in rectPositions {
                let color = NSColor(hexString: rectPosition["backgroundColor"] as! String)
                color?.setFill()

                if (rectPosition["frame"] != nil) {
                    let box = rectPosition["frame"] as! NSRect
                    context.fill(box)
                }
                
                //if rectPosition has key "text"
                if (rectPosition["text"] != nil) {
                    let textDisplay : String = rectPosition["text"] as! String
                    let box = rectPosition["boundingBox"] as! NSRect
                    drawQuartzBlackRomanText(context, textDisplay, box)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if (drawNode != nil) {
            let contextOfParent = NSGraphicsContext.current?.cgContext
            doSimpleRect(contextOfParent!, drawNode as! TreeNode)
        }
    }
}

extension NSColor {
    convenience init?(hexString: String) {
        var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

import Cocoa

func calculateRectPositions(flexDirection: String, containerFrame: NSRect, childrenFlexGrow: [CGFloat], spacing: CGFloat) -> [NSRect] {
    var positions: [NSRect] = []
    let totalFlexGrow = childrenFlexGrow.reduce(0, +)

    if flexDirection == "row" {
        let remainingWidth = containerFrame.width - CGFloat(childrenFlexGrow.count - 1) * spacing
        var startX = containerFrame.minX

        for flexGrow in childrenFlexGrow {
            let itemWidth = (flexGrow / totalFlexGrow) * remainingWidth
            let itemFrame = NSRect(x: startX, y: containerFrame.minY, width: itemWidth, height: containerFrame.height)
            positions.append(itemFrame)
            startX += itemWidth + spacing
        }
    } else if flexDirection == "column" {
        let remainingHeight = containerFrame.height - CGFloat(childrenFlexGrow.count - 1) * spacing
        var startY = containerFrame.minY

        for flexGrow in childrenFlexGrow {
            let itemHeight = (flexGrow / totalFlexGrow) * remainingHeight
            let itemFrame = NSRect(x: containerFrame.minX, y: startY, width: containerFrame.width, height: itemHeight)
            positions.append(itemFrame)
            startY += itemHeight + spacing
        }
    }

    return positions
}

class NSLabel: NSTextField {
    override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
      self.isBezeled = false
      self.drawsBackground = false
      self.isEditable = false
      self.isSelectable = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MyViewController : NSViewController, WebSocketDelegate {
    let textLabel = NSLabel(frame: .init(x: 20, y: 20, width: 200, height: 40))
    var quartzRootView = QuartzRootView(frame: .init(x: 0, y: 0, width: 400, height: 200))
    var request : URLRequest? = nil
    var socket : WebSocket? = nil
    override func loadView() {
        self.view = quartzRootView
        self.request = URLRequest(url: URL(string: "http://localhost:8080")!)
        self.request?.timeoutInterval = 5
        self.socket = WebSocket(request: self.request!)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func offsetTopAndLeft(_ view: NSView, _ depth: Int, _ rootCGPoint: CGPoint) -> CGPoint {
        let top = Int(rootCGPoint.y)
        let left = Int(rootCGPoint.x)
        return CGPoint(x: left, y: top)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            let context = JSContext()
            
            if let filePath = Bundle.main.path(forResource: "bundle", ofType: "js") {
                do {
                    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                    
                    context?.evaluateScript(fileContents)
                    
                    if let rootNodeFunction = context?.objectForKeyedSubscript("getRootNode"), let result = rootNodeFunction.call(withArguments: []) {
                        if let output = result.toString() {
                            let rootNode = parseJSONStringToSimpleTree(output)
                            if (rootNode != nil) {
                                printTree(rootNode)
                                self.quartzRootView.setDrawNodeAndRedraw(rootNode!)
                            }
                        }
                    }
                } catch {
                    print("Error reading file: \(error)")
                }
            } else {
                print("File not found.")
            }
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
            case .connected(_):
                print("conn")
            case .disconnected(_, _):
                print("websocket is disconnected")
            case .text(let receivedString):
                DispatchQueue.main.async {
                    let context = JSContext()
                    context?.evaluateScript(receivedString)
                    
                    if let rootNodeFunction = context?.objectForKeyedSubscript("getRootNode"), let result = rootNodeFunction.call(withArguments: []) {
                        if let output = result.toString() {
                            let rootNode = parseJSONStringToSimpleTree(output)
                            if (rootNode != nil) {
                                let originalFrame : NSRect = self.quartzRootView.frame
                                self.quartzRootView = QuartzRootView(frame: .init(x: 0, y: 0, width: originalFrame.width, height: originalFrame.height))
                                self.view = self.quartzRootView
                                printTree(rootNode)
                                self.quartzRootView.setDrawNodeAndRedraw(rootNode!)
                            }
                        }
                    }
                }
            case .binary(let data):
                print("Received data: \(data.count)")
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                break
            case .error(let error):
                print("error \(error)")
            case .peerClosed:
                print("closed")
            }
    }
}
