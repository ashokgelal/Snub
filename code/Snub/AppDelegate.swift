//
//  AppDelegate.swift
//  Snub
//
//  Created by Ashok Gelal on 10/13/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

import SnubCore
import AsyncSwift

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
        setup()
        logx.debug("Application finish launching")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return contentPopover.contentViewController == nil
    }
    
    private func setup() {
        Async.background { [unowned self] in self.bootstrapper.setupForUI() }
        Async.main { [unowned self] in self.setupPopover() }
        
        // Uncomment the following and add your HockeyApp API Key
        // BITHockeyManager.sharedHockeyManager().configureWithIdentifier("")
        // BITHockeyManager.sharedHockeyManager().startManager()
    }
}

// MARK: ContentViewControllerDelegate
extension AppDelegate: ContentViewControllerDelegate {
    func performDismissContentViewController(sender: AnyObject?) {
        closePopover(sender)
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
        let contentViewController = ContentViewController(nibName: "ContentView", bundle: nil)
        contentViewController?.contentViewControllerDelegate = self
        contentPopover.contentViewController = contentViewController
        setupEventMonitor()
        logx.info("Finished setting up status item")
    }
    
    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            if self.contentPopover.shown {
                self.closePopover(event)
            }
        }
        logx.info("Finished setting up event monitor")
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
