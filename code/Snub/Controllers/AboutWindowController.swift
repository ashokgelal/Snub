//
//  AboutWindowController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/20/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import SnubCore

class AboutWindowController: NSWindowController {

    @IBOutlet weak var titleLbl: NSTextField!
    @IBOutlet weak var versionLbl: NSTextField!
    @IBOutlet weak var licenseLbl: NSTextField!
    @IBOutlet weak var contentView: NSView!
    private var licenseWindowController: NSWindowController!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        contentView.wantsLayer = true
        contentView.layer!.cornerRadius = 10.0
        contentView.layer!.backgroundColor = NSColor.whiteColor().CGColor
        window?.backgroundColor = NSColor.whiteColor()
        versionLbl.stringValue = "Version \(MagicStrings.APP_VERSION)"
        let licensee = NSUserDefaults.standardUserDefaults().stringForKey("licenseeEmail") ?? "Snub"
        licenseLbl.stringValue = "Licensed to \(licensee)"
    }
}

// MARK: Actions
extension AboutWindowController {
    @IBAction func showAcknowledgements(sender: AnyObject) {
        if let url = NSBundle.mainBundle().URLForResource(MagicStrings.ACKNOWLEDGEMENT_FILE, withExtension: "pdf") {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    @IBAction func visitSnubSite(sender: AnyObject) {
        if let url = NSBundle.mainBundle().objectForInfoDictionaryKey("SnubHomepage") as? String {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func showRegistration(sender: AnyObject) {
        self.window?.close()
        licenseWindowController = LicenseWindowController(windowNibName: "LicenseWindow")
        licenseWindowController.showWindow(self)
    }
}
