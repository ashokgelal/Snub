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
    override func windowDidLoad() {
        super.windowDidLoad()
        self.contentView.wantsLayer = true
        self.contentView.layer!.cornerRadius = 10.0
        self.contentView.layer!.backgroundColor = NSColor.whiteColor().CGColor
        self.window?.backgroundColor = NSColor.whiteColor()
        self.window?.center()
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
    
    @IBAction func showRegistration(sender: AnyObject) {
    }
}
