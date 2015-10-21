//
//  GitIgnoreRowView.swift
//  Snub
//
//  Created by Rachana Acharya on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import SnubCore

class GitIgnoreRowView: NSTableCellView {
    weak var rowViewDelegate: GitIgnoreRowViewDelegate?
    @IBOutlet weak var addMenuItem: NSMenuItem!
    @IBOutlet weak var appendMenuItem: NSMenuItem!
    
    var gitIgnoreItem: GitIgnoreFileItem! {
        didSet {
            textField!.stringValue = gitIgnoreItem.name
        }
    }
}

// Mark: Menu Actions
extension GitIgnoreRowView {
    @IBAction func add(sender: AnyObject?) {
        rowViewDelegate?.performAdd?(gitIgnoreItem)
    }
    
    @IBAction func append(sender: AnyObject?) {
        rowViewDelegate?.performAppend?(gitIgnoreItem)
    }
}

// Mark: Protocols
@objc protocol GitIgnoreRowViewDelegate {
    optional func performAdd(sender: GitIgnoreFileItem)
    optional func performAppend(sender: GitIgnoreFileItem)
}
