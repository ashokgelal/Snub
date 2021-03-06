//
//  AboutWindowController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/20/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

import Cocoa
import SnubCore

class AboutWindowController: NSWindowController {
    @IBOutlet weak var titleLbl: NSTextField!
    @IBOutlet weak var versionLbl: NSTextField!
    @IBOutlet weak var contentView: NSView!
    private var licenseWindowController: NSWindowController!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        contentView.wantsLayer = true
        contentView.layer!.cornerRadius = 10.0
        contentView.layer!.backgroundColor = NSColor.whiteColor().CGColor
        window?.backgroundColor = NSColor.whiteColor()
        versionLbl.stringValue = "Version \(MagicStrings.APP_VERSION)"
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
}
