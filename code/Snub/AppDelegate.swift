//
//  AppDelegate.swift
//  Snub
//
//  Created by Ashok Gelal on 10/13/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import SnubCore
import AsyncSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let bootstrapper: Bootstrapper
    private let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    private let contentPopover = NSPopover()
    private var eventMonitor: EventMonitor?
    private var licenseController: LicenseWindowController!
    
    override init() {
        bootstrapper = Bootstrapper.sharedInstance
        super.init()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // verifyLicense()
        setup()
        logx.info("Application finish launching")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return contentPopover.contentViewController == nil
    }
    
    private func verifyLicense() {
        licenseController = LicenseWindowController()
        licenseController.licenseWindowControllerDelegate = self
        licenseController.verify()
    }
}

// MARK: ContentViewControllerDelegate
extension AppDelegate: ContentViewControllerDelegate {
    func performDismissContentViewController(sender: AnyObject?) {
        closePopover(sender)
    }
}

// MARK: LicenseWindowControllerDelegate
extension AppDelegate: LicenseWindowControllerDelegate {
    func didFinishVerifyingLicense(licenseInfo: LicenseInfo?, error: NSError?) {
        if let err = error {
            logx.warning("Error verifying remote license \(err.localizedDescription)")
        } else {
            NSUserDefaults.standardUserDefaults().setObject(licenseInfo?.key, forKey: "licenseKey")
            NSUserDefaults.standardUserDefaults().setObject(licenseInfo?.email, forKey: "licenseeEmail")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if contentPopover.contentViewController == nil {
                setup()
            }
        }
    }
    
    private func setup() {
        Async.background { [unowned self] in self.bootstrapper.setupForUI() }
        Async.main { [unowned self] in self.setupPopover() }
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
