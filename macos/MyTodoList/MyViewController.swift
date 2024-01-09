//
//  MyViewController.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 11/30/23.
//

import AppKit
import Cocoa
import CoreText
import JavaScriptCore
import Starscream

class MyViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshWindow(_:)), name: .refreshWindow, object: nil)
        DispatchQueue.main.async {
            let context = JSContext()

            if let filePath = Bundle.main.path(forResource: "main.bundle", ofType: "js") {
                do {
                    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                    context?.evaluateScript(fileContents)

                    if let rootNodeFunction = context?.objectForKeyedSubscript("getRootNode"), let result = rootNodeFunction.call(withArguments: []) {
                        if let output = result.toString() {
                            let rootTreeNode = try parseJSONStringToTree(output)
                            if let rootView = buildViewHierarchy(from: rootTreeNode, superView: self.view) {
                                self.view.addSubview(rootView)
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

    @objc func handleRefreshWindow(_ notification: Notification) {
        // Handle the login event
        DispatchQueue.main.async {
            let context = JSContext()
            
            do {
                let fileContents = try String(contentsOfFile: localPath, encoding: .utf8)
                context?.evaluateScript(fileContents)

                if let rootNodeFunction = context?.objectForKeyedSubscript("getRootNode"), let result = rootNodeFunction.call(withArguments: []) {
                    if let output = result.toString() {
                        print(output)
                        let rootTreeNode = try parseJSONStringToTree(output)
                        let screenFrame = NSRect(x: 0, y: 0, width: 800, height: 600)
                        let frame = NSRect(origin: .zero, size: screenFrame.size)
                        self.view = NSView(frame: frame)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // waits 1 second
                            if let rootView = buildViewHierarchy(from: rootTreeNode, superView: self.view) {
                                self.view.addSubview(rootView)
                            }
                        }
                        
                    }
                }
            } catch {
                print("Error reading file: \(error)")
            }
        }
    }
}
