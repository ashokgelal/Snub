//
//  MasterGitIgnoreTabViewItemController.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class MasterGitIgnoreTabViewItemController: NSViewController {
    @IBInspectable var cellIdentifier: String!
    @IBOutlet weak var tableView: NSTableView!
    
    var gitIgnoreItems: [GitIgnoreFileItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedFolders: [NSURL] = [] {
        didSet {
            if selectedFolders.count > 0 {
                gitIgnoreItems = GitIgnoreFileManager.instance.fetchMasterGitIgnoreItems()
            } else {
                gitIgnoreItems = []
            }
        }
    }
}

// MARK: Table View Delegates
extension MasterGitIgnoreTabViewItemController: NSTableViewDelegate, NSTableViewDataSource  {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return gitIgnoreItems.count
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? GitIgnoreRowView else {
            return nil
        }
        let result = gitIgnoreItems[row]
        cell.gitIgnoreItem = result
        cell.rowViewDelegate = self
        return cell
    }
}

// MARK: Row View Delegates
extension MasterGitIgnoreTabViewItemController: GitIgnoreRowViewDelegate {
    func performAdd(result: GitIgnoreFileItem) {
        // todo: show spinner
        selectedFolders.forEach {
            url in
            do {
                try GitIgnoreFileManager.instance.addGitIgnoreWithId(result.id, toPath: url)
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                DDLogError("Didn't find source .gitignore with id: \(result.id)")
            } catch let error as NSError {
                DDLogError("Error adding .gitignore: \(error.localizedDescription)")
            }
        }
        // todo: show success
    }
    
    func performAppend(result: GitIgnoreFileItem) {
        // todo: show spinner
        selectedFolders.forEach {
            url in
            do {
                try GitIgnoreFileManager.instance.appendGitIgnoreWithId(result.id, toPath: url)
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                DDLogError("Didn't find source .gitignore with id: \(result.id)")
            } catch let error as NSError {
                DDLogError("Error appending .gitignore: \(error.localizedDescription)")
            }
        }
        // todo: show success
    }
}
