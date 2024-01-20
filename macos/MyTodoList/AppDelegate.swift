//
//  AppDelegate.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 11/30/23.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var myName: String = "AppDelegate"
    var wc: NSWindowController!
    var window: NSWindow!

    func createWindow() {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let frame = NSRect(origin: .zero, size: screenFrame.size)

        window = NSWindow(contentRect: frame, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.contentViewController = MyViewController()

        wc = NSWindowController(window: window)
        wc.showWindow(self)
    }

    @objc func handleCreateWindow(_ notification: Notification) {
        // Handle the login event
        DispatchQueue.main.async { [self] in
            createWindow()
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCreateWindow(_:)), name: .createWindow, object: nil)
        startServer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
