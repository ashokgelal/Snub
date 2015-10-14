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

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
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
            button.action = Selector("printQuote:")
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
}

