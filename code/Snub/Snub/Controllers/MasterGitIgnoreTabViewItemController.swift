//
//  MasterGitIgnoreTabViewItemController.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import Async
import FuzzySearch

class MasterGitIgnoreTabViewItemController: NSViewController {
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBInspectable var cellIdentifier: String!
    @IBOutlet weak var tableView: NSTableView!
    
    var selectedFolders: [NSURL] = []
    var searchResults: [GitIgnoreFileItem] = [] {
        didSet { tableView.reloadData() }
    }
    
    var gitIgnoreItems: [GitIgnoreFileItem] = [] {
        didSet { searchResults = gitIgnoreItems }
    }
    
    func loadSelectedFolders(selectedFolders: [NSURL]) {
        if selectedFolders.count > 0 {
            var items: [GitIgnoreFileItem] = []
            progressIndicator.startAnimation(self)
            Async.background {
                items = GitIgnoreFileManager.instance.fetchMasterGitIgnoreItems()
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

// MARK: Actions
extension MasterGitIgnoreTabViewItemController {
    @IBAction func search(sender: NSTextField) {
        let searchText = sender.stringValue
        if searchText == "" {
            searchResults = gitIgnoreItems
        } else {
            searchResults = gitIgnoreItems.filter {
                item in
                return FuzzySearch.score(originalString: item.name, stringToMatch: searchText, fuzziness: 0.8) > 0.5
            }
        }
    }
}
