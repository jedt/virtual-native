//
//  ViewController.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 11/30/23.
//

import AppKit
import JavaScriptCore

class MyView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let color = NSColor(red: 37/255, green: 38/255, blue: 39/255, alpha: 1)
        color.set()
        dirtyRect.fill()
    }
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


class MyViewController : NSViewController {
    let textLabel = NSLabel(frame: .init(x: 20, y: 20, width: 200, height: 40))
    private var newView: MyView = {
        let frame: NSRect = NSRect(origin: .zero, size: CGSize(width: 300, height: 300))
        let view = MyView(frame: frame)
        view.wantsLayer = true;
        view.layer!.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        
        let font = NSFont(name: "SF Mono", size: 16)
        textLabel.textColor = .white
        textLabel.stringValue = "Hello, world."
        textLabel.font = font
        newView.addSubview(textLabel)
        self.view = view
        self.view.addSubview(newView)
        print("MyViewController.loadView");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MyViewController.viewDidLoad");
        
        let context = JSContext()

        if let filePath = Bundle.main.path(forResource: "bundle", ofType: "js") {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)

                context?.evaluateScript(fileContents)
                
                //function id
                
                if let helloFunction = context?.objectForKeyedSubscript("getRootNode"), let result = helloFunction.call(withArguments: []) {
                    if let output = result.toString() {
                        print(output)
                    }
                }
            } catch {
                print("Error reading file: \(error)")
            }
        } else {
            print("File not found.")
        }


        // Escape backslashes in the code string
        
    }

}
