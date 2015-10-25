//
//  MasterGitIgnoreTabViewItemController.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import AsyncSwift
import FuzzySearch
import SnubCore
import CocoaLumberjack

class MasterGitIgnoreTabViewItemController: NSViewController {
    @IBInspectable var cellIdentifier: String!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var statusImage: NSImageView!
    
    var selectedFolders: [NSURL] = []
    var searchResults: [GitIgnoreFileItem] = [] {
        didSet { tableView.reloadData() }
    }
    
    var gitIgnoreItems: [GitIgnoreFileItem] = [] {
        didSet { searchResults = gitIgnoreItems }
    }
    
    func loadSelectedFolders(selectedFolders: [NSURL]) {
        self.selectedFolders = selectedFolders
        if selectedFolders.count > 0 {
            var items: [GitIgnoreFileItem] = []
            progressIndicator.startAnimation(self)
            Async.background {
                items = GitIgnoreFileManager.sharedInstance.fetchMasterGitIgnoreItems()
            }.main { [unowned self] in
                self.gitIgnoreItems = items
                self.progressIndicator.stopAnimation(self)
            }
        } else {
            gitIgnoreItems = []
        }
    }
}

// MARK: Table View Delegates
extension MasterGitIgnoreTabViewItemController: NSTableViewDelegate, NSTableViewDataSource  {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? GitIgnoreRowView else {
            return nil
        }
        let result = searchResults[row]
        cell.gitIgnoreItem = result
        cell.rowViewDelegate = self
        return cell
    }
}

// MARK: Row View Delegates
extension MasterGitIgnoreTabViewItemController: GitIgnoreRowViewDelegate {
    func performAdd(result: GitIgnoreFileItem) {
        progressIndicator.startAnimation(self)
        var succeeded = false
        Async.background { [unowned self] in
            self.selectedFolders.forEach {
                do {
                    try GitIgnoreFileManager.sharedInstance.addGitIgnoreWithId(result.id, toPath: $0)
                    succeeded = true
                } catch GitIgnoreError.SourceGitIgnoreNotFound {
                    DDLogError("Didn't find source .gitignore with id: \(result.id)")
                } catch let error as NSError {
                    DDLogError("Error adding .gitignore: \(error.localizedDescription)")
                }
            }
        } .main { [unowned self] in
            self.progressIndicator.stopAnimation(self)
            if succeeded {
                self.showStatusImage(true, tooltip: "Successfully added \(result.name) .gitignore")
            } else {
                self.showStatusImage(false, tooltip: "Error adding \(result.name) .gitignore")
            }
        }
    }
    
    func performAppend(result: GitIgnoreFileItem) {
        progressIndicator.startAnimation(self)
        var succeeded = false
        Async.background { [unowned self] in
            self.selectedFolders.forEach {
                do {
                    try GitIgnoreFileManager.sharedInstance.appendGitIgnoreWithId(result.id, toPath: $0)
                    succeeded = true
                } catch GitIgnoreError.SourceGitIgnoreNotFound {
                    DDLogError("Didn't find source .gitignore with id: \(result.id)")
                } catch let error as NSError {
                    DDLogError("Error appending .gitignore: \(error.localizedDescription)")
                }
            }
            }.main { [unowned self] in
                self.progressIndicator.stopAnimation(self)
                if succeeded {
                    self.showStatusImage(true, tooltip: "Successfully appended \(result.name) .gitignore")
                } else {
                    self.showStatusImage(false, tooltip: "Error appending \(result.name) .gitignore")
                }
        }
    }
    
    private func showStatusImage(isSuccessful: Bool, tooltip: String) {
        if isSuccessful {
            statusImage.image = NSImage(named: "checkIcon")
        } else {
            statusImage.image = NSImage(named: "crossIcon")
        }
        
        statusImage.toolTip = tooltip
        statusImage.animator().hidden = false
        delay(5) { [unowned self] in
            self.statusImage.animator().hidden = true
            self.statusImage.toolTip = ""
        }
    }
}

// MARK: Actions
extension MasterGitIgnoreTabViewItemController {
    @IBAction func search(sender: NSTextField) {
        progressIndicator.startAnimation(self)
        defer {
            progressIndicator.stopAnimation(self)
        }
        let searchText = sender.stringValue
        if searchText == "" {
            searchResults = gitIgnoreItems
        } else {
            searchResults = gitIgnoreItems.filter {
                return FuzzySearch.score(originalString: $0.name, stringToMatch: searchText, fuzziness: 0.8) > 0.5
            }
        }
    }
}
