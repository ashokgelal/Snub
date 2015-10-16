//
//  ContentViewController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController {
    @IBOutlet weak var selectedPathLbl: NSTextField!
    private var selectedFolders: [NSURL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        showSelectedFolder()
    }
    
    private func showSelectedFolder() {
        selectedFolders = FinderSelectionProvider.instance.getSelectedFolders()
        if(selectedFolders.count == 1) {
            let folder = selectedFolders.first!.path! as NSString
            selectedPathLbl.stringValue = "\(folder.stringByAbbreviatingWithTildeInPath)"
        } else if(selectedFolders.count > 1) {
            selectedPathLbl.stringValue = "\(selectedFolders.count) folders selected"
        } else {
            selectedPathLbl.stringValue = "No folder selected"
        }
    }
}

// MARK: Setting Actions
extension ContentViewController {
    @IBAction func quitSnub(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(sender)
    }
}
