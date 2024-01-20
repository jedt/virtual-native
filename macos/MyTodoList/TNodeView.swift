//
//  TNodeView.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 1/7/24.
//

import AppKit

class TNodeView: NSView {
    public var tagName : String?
    override var isFlipped: Bool {
        return false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
