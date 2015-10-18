//
//  ContentViewController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import Async

class ContentViewController: NSViewController {
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var gitIgnoreSelectionTab: NSTabView!
    @IBOutlet weak var selectedPathBtn: NSButton!
    @IBOutlet weak var currentGitIgnoreLbl: NSTextField!
    @IBOutlet var suggestedTabViewItemController: SuggestedTabViewItemController!
    @IBOutlet var masterGitIgnoreTabViewItemController: MasterGitIgnoreTabViewItemController!
    
    private var currentGitIgnoreFilePaths: Array<NSURL?> = []
    
    override func viewDidAppear() {
        let selectedFolders = FinderSelectionProvider.instance.getSelectedFolders()
        showSelectedFolder(selectedFolders)
        guard selectedFolders.count > 0 else {
            currentGitIgnoreLbl.stringValue = "[No folders selected]"
            return
        }
        var gitIgnoreFilesWithTheirPaths: [NSURL:NSURL?] = [:]
        progressIndicator.startAnimation(self)
        Async.background {
            do {
                gitIgnoreFilesWithTheirPaths = try GitIgnoreTypeDetector.instance.detect(selectedFolders)
            } catch let error as NSError {
                DDLogError("Error detecting .gitignore types: \(error.localizedDescription)")
            }
        }.main { [unowned self] in
            self.progressIndicator.stopAnimation(self)
            self.suggestedTabViewItemController.loadSelectedFolders(selectedFolders)
            self.masterGitIgnoreTabViewItemController.loadSelectedFolders(selectedFolders)
            self.currentGitIgnoreFilePaths = self.displayCurrentGitIgnoreValues(gitIgnoreFilesWithTheirPaths)
        }
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if(menuItem.action == Selector("editCurrent:") || menuItem.action == Selector("deleteCurrent:")) {
            return currentGitIgnoreFilePaths.count > 0
        }
        return true
    }
    
    private func showSelectedFolder(selectedFolders: [NSURL]) {
        var outputVal = "[No folders selected]"
        selectedPathBtn.enabled = false
        if(selectedFolders.count == 1) {
            let folder = selectedFolders.first!.path! as NSString
            outputVal = "\(folder.stringByAbbreviatingWithTildeInPath)"
            selectedPathBtn.enabled = true
        } else if(selectedFolders.count > 1) {
            outputVal = "\(selectedFolders.count) folders selected"
            selectedPathBtn.enabled = true
        }
        selectedPathBtn.title = outputVal
    }
    
    private func displayCurrentGitIgnoreValues(ignoreDict : [NSURL: NSURL?]) -> Array<NSURL?> {
        let filePaths = Array(ignoreDict.values.filter { $0 != nil })
        var outputVal = "[No .gitignore files detected]"
        if filePaths.count == 1 {
            do {
                let ignoreTypes = try GitIgnoreTypeDetector.instance.identify(filePaths.first!!)
                if ignoreTypes.count > 0 {
                    outputVal = ignoreTypes.joinWithSeparator(" + ")
                } else {
                    outputVal = "[Couldn't determine .gitignore's type]"
                }
            } catch let error as NSError {
                outputVal = "[Error identifying .gitignore's type]"
                DDLogError("Error identifying: \(error.localizedDescription)")
            }
        } else if filePaths.count > 1 {
            outputVal = "Multiple .gitignore files detected"
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
    
    @IBAction func openSelectedFolders(sender: AnyObject) {
        suggestedTabViewItemController.selectedFolders.forEach {
            NSWorkspace.sharedWorkspace().openURL($0)
        }
    }
    
    @IBAction func deleteCurrent(sender: AnyObject) {
        currentGitIgnoreFilePaths.forEach {
            let path = $0!.path!
            do {
                try NSFileManager.defaultManager().trashItemAtURL($0!, resultingItemURL: nil)
                DDLogVerbose("Deleted file \(path)")
            } catch let error as NSError {
                DDLogWarn("Error deleting file \(path): \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func editCurrent(sender: AnyObject) {
        currentGitIgnoreFilePaths.forEach {
            let path = $0!.path!
            NSWorkspace.sharedWorkspace().openFile(path)
            DDLogVerbose("Opened TextEdtior to edit \(path)")
        }
    }
}
