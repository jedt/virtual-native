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
        window = NSWindow()
        window.styleMask = NSWindow.StyleMask(rawValue: 0xf)
        window.backingType = .buffered
        window.contentViewController = MyViewController()
        let frame = NSRect(origin: .zero, size: .init(width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height))
        window.setFrame(frame, display: false)

        wc = NSWindowController()
        print(wc.isWindowLoaded)
        wc.contentViewController = window.contentViewController
        wc.window = window
        wc.showWindow(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        createWindow()
        startServer()
//        connectToBundler()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
