//
//  ContentViewController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController {
    @IBOutlet weak var gitIgnoreSelectionTab: NSTabView!
    @IBOutlet weak var selectedPathLbl: NSTextField!
    @IBOutlet weak var currentGitIgnoreLbl: NSTextField!
    @IBOutlet var suggestedTabViewItemController: SuggestedTabViewItemController!
    @IBOutlet var masterGitIgnoreTabViewItemController: MasterGitIgnoreTabViewItemController!
    
    private var currentGitIgnoreFilePaths: Array<NSURL?> = []
    
    override func viewDidAppear() {
        let selectedFolders = FinderSelectionProvider.instance.getSelectedFolders()
        showSelectedFolder(selectedFolders)
        let gitIgnoreFilesWithTheirPaths = GitIgnoreTypeDetector.instance.detect(selectedFolders)
        currentGitIgnoreFilePaths = displayCurrentGitIgnoreValues(gitIgnoreFilesWithTheirPaths)
        suggestedTabViewItemController.selectedFolders = selectedFolders
        masterGitIgnoreTabViewItemController.selectedFolders = selectedFolders
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if(menuItem.action == Selector("editCurrent:") || menuItem.action == Selector("deleteCurrent:")) {
            return currentGitIgnoreFilePaths.count > 0
        }
        return true
    }
    
    private func showSelectedFolder(selectedFolders: [NSURL]) {
        if(selectedFolders.count == 1) {
            let folder = selectedFolders.first!.path! as NSString
            selectedPathLbl.stringValue = "\(folder.stringByAbbreviatingWithTildeInPath)"
        } else if(selectedFolders.count > 1) {
            selectedPathLbl.stringValue = "\(selectedFolders.count) folders selected"
        } else {
            selectedPathLbl.stringValue = "No folder selected"
        }
    }
    
    private func displayCurrentGitIgnoreValues(ignoreDict : [NSURL: NSURL?]) -> Array<NSURL?> {
        let filePaths = Array(ignoreDict.values.filter { $0 != nil })
        var outputVal = "[No .gitignore detected]"
        if filePaths.count == 1 {
            do {
                let ignoreTypes = try GitIgnoreTypeDetector.instance.identify(filePaths.first!!)
                if ignoreTypes.count > 0 {
                    outputVal = ignoreTypes.joinWithSeparator(" + ")
                } else {
                    outputVal = "[Couldn't determine .gitignore type]"
                }
            } catch let error as NSError {
                DDLogError("Error identifying: \(error.localizedDescription)")
            }
        } else if filePaths.count > 1 {
            outputVal = "Multiple .gitignores detected"
        }
        currentGitIgnoreLbl.stringValue = outputVal
        return filePaths
    }
}

// MARK: Setting Actions
extension ContentViewController {
    @IBAction func quitSnub(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(sender)
    }
}

// MARK: Other Actions
extension ContentViewController {
    @IBAction func changeGitIgnoreSelectionType(sender: NSSegmentedControl) {
        gitIgnoreSelectionTab.selectTabViewItemAtIndex(sender.selectedSegment)
    }
    
    @IBAction func deleteCurrent(sender: AnyObject) {
    }
    
    @IBAction func editCurrent(sender: AnyObject) {
        currentGitIgnoreFilePaths.forEach {
            let path = $0!.path!
            NSWorkspace.sharedWorkspace().openFile(path)
            DDLogVerbose("Opened TextEdtior to edit \(path)")
        }
    }
}
