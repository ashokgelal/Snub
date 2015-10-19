//
//  AppDelegate.swift
//  Snub
//
//  Created by Ashok Gelal on 10/13/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import SnubCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let bootstrapper: Bootstrapper
    private let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    private let contentPopover = NSPopover()
    private var eventMonitor: EventMonitor?
    
    override init() {
        bootstrapper = Bootstrapper.sharedInstance
        super.init()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        bootstrapper.setupForUI()
        setupPopover()
        DDLogVerbose("Application finish launching")
    }
}

// MARK: Status Item
extension AppDelegate {
    private func setupPopover() {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            button.action = Selector("togglePopover:")
            button.toolTip = MagicStrings.APPNAME
        }
        contentPopover.animates = false
        contentPopover.contentViewController = ContentViewController(nibName: "ContentViewController", bundle: nil)
        setupEventMonitor()
        DDLogVerbose("Finished setting up status item")
    }
    
    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            if self.contentPopover.shown {
                self.closePopover(event)
            }
        }
        DDLogVerbose("Finished setting up event monitor")
    }
    
    func togglePopover(sender: AnyObject?) {
        if contentPopover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            contentPopover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
        }
        eventMonitor?.start()
    }
    
    private func closePopover(sender: AnyObject?) {
        contentPopover.performClose(sender)
        eventMonitor?.stop()
    }
}
