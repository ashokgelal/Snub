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
        defaultDebugLevel = DDLogLevel.Verbose
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDTTYLogger.sharedInstance().colorsEnabled = true
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            button.action = Selector("togglePopover:")
            button.toolTip = "Snub"
        }
        contentPopover.animates = false
        contentPopover.contentViewController = ContentViewController(nibName: "ContentViewController", bundle: nil)
        setupEventMonitor()
        GitIgnoreFileManager.instance
    }
    
    func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            if self.contentPopover.shown {
                self.closePopover(event)
            }
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

class GitIgnoreFileManager {
    private let appDirectoryName = "Snub"
    class var instance: GitIgnoreFileManager {
        struct Singleton {
            private static let instance = GitIgnoreFileManager()
        }
        return Singleton.instance
    }
    
    private init() {
        setupApplicationSupportDirectory()
        //let url = NSBundle.mainBundle().URLForResource("gitignore-master", withExtension: "zip")
    }
    
    private func setupApplicationSupportDirectory() {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        if let supportDirectory = paths.first {
            let appDirectoryPath = (supportDirectory as NSString).stringByAppendingPathComponent(appDirectoryName)
            let fm = NSFileManager.defaultManager()
            var isDir: ObjCBool = false
            let fileExists = fm.fileExistsAtPath(appDirectoryPath, isDirectory: &isDir)
            if(fileExists && isDir) {
                DDLogVerbose("App Support Directory \(appDirectoryPath) already exists")
                return
            }
            do {
                try fm.createDirectoryAtPath(appDirectoryPath, withIntermediateDirectories: false, attributes: nil)
                DDLogVerbose("Successfully created App Support Directory \(appDirectoryPath)")
            } catch {
                DDLogError("Cannot create a directory \(appDirectoryPath)")
            }
        }
    }
}
