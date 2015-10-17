//
//  ContentViewController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class ContentTabViewController: NSTabViewController {
}

class ContentViewController: NSViewController {
    @IBOutlet weak var gitIgnoreSelectionTab: NSTabView!
    @IBOutlet weak var selectedPathLbl: NSTextField!
    @IBOutlet weak var currentGitIgnoreLbl: NSTextField!
    @IBOutlet var suggestedTabViewItemController: SuggestedTabViewItemController!
    
    override func viewDidAppear() {
        let selectedFolders = FinderSelectionProvider.instance.getSelectedFolders()
        showSelectedFolder(selectedFolders)
        let gitIgnoreFilesWithTheirPaths = detectGitIgnores(selectedFolders)
        displayCurrentGitIgnoreValues(gitIgnoreFilesWithTheirPaths)
        suggestedTabViewItemController.selectedFolders = selectedFolders
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
    
    private func detectGitIgnores(selectedFolders: [NSURL]) -> [NSURL: NSURL?] {
        return GitIgnoreDetector.instance.detect(selectedFolders)
    }
    
    private func displayCurrentGitIgnoreValues(ignoreDict : [NSURL: NSURL?]) {
        let gitIgnoreFilePaths = Array(ignoreDict.values.filter { $0 != nil })
        var outputVal = "[No .gitignore detected]"
        if gitIgnoreFilePaths.count == 1 {
            do {
                let ignoreTypes = try GitIgnoreDetector.instance.identify(gitIgnoreFilePaths.first!!)
                if ignoreTypes.count > 0 {
                    outputVal = ignoreTypes.joinWithSeparator("+")
                } else {
                    outputVal = "[Couldn't determine .gitignore type]"
                }
            } catch let error as NSError {
                DDLogError("Error identifying: \(error.localizedDescription)")
            }
        } else if gitIgnoreFilePaths.count > 1 {
            outputVal = "Multiple .gitignores detected"
        }
        currentGitIgnoreLbl.stringValue = outputVal
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
}
