//
//  GitIgnoreRowView.swift
//  Snub
//
//  Created by Rachana Acharya on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class GitIgnoreRowView: NSTableCellView {
    weak var rowViewDelegate: GitIgnoreRowViewDelegate?
    @IBOutlet weak var addMenuItem: NSMenuItem!
    @IBOutlet weak var appendMenuItem: NSMenuItem!
    
    var projectDetectionResult: ProjectDetectionResult! {
        didSet {
            textField!.stringValue = projectDetectionResult.projectType
        }
    }
}

// Mark: Menu Actions
extension GitIgnoreRowView {
    @IBAction func add(sender: AnyObject?) {
        rowViewDelegate?.performAdd?(projectDetectionResult)
    }
    
    @IBAction func append(sender: AnyObject?) {
        rowViewDelegate?.performAppend?(projectDetectionResult)
    }
}
