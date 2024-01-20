//
//  BridgedComponent.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 1/20/24.
//

import AppKit

class BrigedComponentClass: NSButton {
    var bridgeID: String?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.target = self
        self.action = #selector(buttonAction)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.target = self
        self.action = #selector(buttonAction)
    }

    @objc func buttonAction(sender: BrigedComponentClass) {
        if let bridgeID = sender.bridgeID {
            do {
                let output = try invokeJsAsync(withBridgeID: bridgeID)
                print(output);
            }
            catch {
                print("error reading bundle")
            }
        }
    }
}
