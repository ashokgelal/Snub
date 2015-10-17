//
//  GitIgnoreRowView.swift
//  Snub
//
//  Created by Rachana Acharya on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class GitIgnoreRowView: NSTableCellView {
    @IBOutlet weak var addMenuItem: NSMenuItem!
    @IBOutlet weak var replaceMenuItem: NSMenuItem!
    @IBOutlet weak var appendMenuItem: NSMenuItem!
}

// Mark: Menu Actions
extension GitIgnoreRowView {
    
    @IBAction func add(sender: AnyObject?) {
        DDLogError("Boom!")
    }
    
    @IBAction func replace(sender: AnyObject?) {
        DDLogError("Boom! Replace")
    }
    
    @IBAction func append(sender: AnyObject?) {
        DDLogError("Boom! Replace")
    }
}
