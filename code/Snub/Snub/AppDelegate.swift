//
//  AppDelegate.swift
//  Snub
//
//  Created by Ashok Gelal on 10/13/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import CocoaLumberjack

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    let contentPopover = NSPopover()
    var eventMonitor: EventMonitor?
    
    override init() {
        super.init()
        setupLogger()
    }
    
    private func setupLogger(){
        defaultDebugLevel = DDLogLevel.Debug
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDTTYLogger.sharedInstance().colorsEnabled = true
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = Selector("togglePopover:")
        }
        contentPopover.contentViewController = ContentViewController(nibName: "ContentViewController", bundle: nil)
        setupEventMonitor()
    }
    
    func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            if self.contentPopover.shown {
                self.closePopover(event)
            }
        }
    }
    
    func printQuote(sender: AnyObject) {
        let items = FinderSelectionProvider.instance.getSelectedItems()
        for item in items {
            DDLogDebug(item.path!)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func togglePopover(sender: AnyObject?) {
        if contentPopover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            contentPopover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        contentPopover.performClose(sender)
        eventMonitor?.stop()
    }
}
