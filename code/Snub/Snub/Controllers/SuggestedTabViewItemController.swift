//
//  SuggestedTabViewItemController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class SuggestedTabViewItemController: NSViewController {
    @IBInspectable var cellIdentifier: String!
    @IBOutlet weak var tableView: NSTableView!
    
    var selectedFolders: [NSURL] = [] {
        didSet {
            determineSuggestedProjectTypes(selectedFolders)
        }
    }
    
    private var suggestedProjectTypes: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func determineSuggestedProjectTypes(selectedFolders : [NSURL]) {
        var outputVal = "[Couldn't determine project type]"
        if selectedFolders.count == 1 {
            do {
                suggestedProjectTypes = try ProjectDetector.instance.identify(selectedFolders.first!)
                let combined = suggestedProjectTypes.joinWithSeparator("+")
                outputVal = "Suggested project types: \(combined)"
            } catch let error as NSError {
                DDLogError("Error identifying: \(error.localizedDescription)")
            }
        } else if selectedFolders.count > 1 {
            outputVal = "Snub suggestion only works with 1 selected project"
        }
        DDLogVerbose(outputVal)
    }
}

// MARK: Table View Delegates
extension SuggestedTabViewItemController: NSTableViewDelegate, NSTableViewDataSource  {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return suggestedProjectTypes.count
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? GitIgnoreRowView else {
            return nil
        }
        cell.textField!.stringValue = suggestedProjectTypes[row]
        return cell
    }
}