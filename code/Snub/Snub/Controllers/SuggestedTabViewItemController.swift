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
    
    private var projectDetectionResults: [ProjectDetectionResult] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func determineSuggestedProjectTypes(selectedFolders : [NSURL]) {
        var outputVal = "[Couldn't determine project type]"
        if selectedFolders.count == 1 {
            do {
                projectDetectionResults = try ProjectDetector.instance.identify(selectedFolders.first!)
                if(projectDetectionResults.count > 0) {
                    outputVal = "Was able to determine project types"
                }
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
        return projectDetectionResults.count
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? GitIgnoreRowView else {
            return nil
        }
        let result = projectDetectionResults[row]
        cell.projectDetectionResult = result
        cell.rowViewDelegate = self
        return cell
    }
}

// MARK: Row View Delegates
extension SuggestedTabViewItemController: GitIgnoreRowViewDelegate {
    func performAdd(result: ProjectDetectionResult) {
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
    
    func performAppend(result: ProjectDetectionResult) {
        // todo: show spinner
        selectedFolders.forEach {
            url in
            GitIgnoreFileManager.instance.appendGitIgnoreWithId(result.id, toPath: url)
        }
        // todo: show success
    }
}