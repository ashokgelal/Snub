//
//  LicenseWindowController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/21/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import SnubCore
import AsyncSwift

class LicenseWindowController: NSWindowController {
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var licenseTextField: NSTextField!
    @IBOutlet weak var errorLbl: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var registerBtn: NSButton!
    weak var licenseWindowControllerDelegate: LicenseWindowControllerDelegate?
    
    private lazy var licenseService: LicenseService = {
        return LicenseService(reverificationDays: 30)
    }()
    
    convenience init() {
        self.init(windowNibName: "LicenseWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        contentView.wantsLayer = true
        contentView.layer!.cornerRadius = 10.0
        contentView.layer!.backgroundColor = NSColor.whiteColor().CGColor
        registerBtn.keyEquivalent = "\r"
        window?.backgroundColor = NSColor.whiteColor()
    }
    
    func verify() {
        do {
            guard let verification = try licenseService.checkLocalLicenseKey() else {
                logx.warning("No local license")
                showWindow(self)
                return
            }
            if verification.email != "" {
                logx.info("Local license verified; email: \(verification.email); key: \(verification.key)")
                self.licenseWindowControllerDelegate?.didFinishVerifyingLicense(verification, error: nil)
                return
            }
            logx.info("Empty email; re-verifying the key")
            licenseService.verifyLicenseKey(verification.key) {
                [unowned self]
                (licenseInfo, error) in
                logx.info("Re-verification completed")
                if error == nil {
                    self.licenseWindowControllerDelegate?.didFinishVerifyingLicense(verification, error: nil)
                } else {
                    logx.warning("Re-verification failed. Showing License window. Error is: \(error?.localizedDescription)")
                    self.showWindow(self)
                }
            }
        } catch let error as LicenseError {
            logx.warning("License error while verifying license: \(error)")
            showWindow(self)
        } catch let error as NSError {
            logx.warning("Error while verifying license: \(error.localizedDescription)")
            showWindow(self)
        }
    }
    
    @IBAction func register(sender: AnyObject) {
        let key = licenseTextField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if key.characters.count > 0 {
            errorLbl.hidden = true
            progressIndicator.startAnimation(self)
            registerBtn.enabled = false
            
            defer {
                progressIndicator.stopAnimation(self)
                registerBtn.enabled = true
            }
            
            licenseService.verifyLicenseKey(key) {
                [unowned self]
                (licenseInfo, error) in
                if error == nil {
                    logx.notice("Registration completed")
                    self.licenseWindowControllerDelegate?.didFinishVerifyingLicense(licenseInfo, error: error)
                    Async.main { self.close() }
                } else {
                    logx.warning("Error registering")
                    Async.main { self.errorLbl.hidden = false }
                }
            }
        }
    }
    
    @IBAction func visitSnubSite(sender: AnyObject) {
        if let url = NSBundle.mainBundle().objectForInfoDictionaryKey("SnubHomepage") as? String {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
        }
    }
}
