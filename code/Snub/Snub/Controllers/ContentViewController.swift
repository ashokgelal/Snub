//
//  ContentViewController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController {
    @IBOutlet weak var selectedPathLbl: NSTextField!
    @IBOutlet weak var currentGitIgnoreLbl: NSTextField!
    private var selectedFolders: [NSURL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        showSelectedFolder()
        let ignoreDict = detectGitIgnores()
        showCurrentGitIgnoreValues(ignoreDict)
        
    }
    
    private func showSelectedFolder() {
        selectedFolders = FinderSelectionProvider.instance.getSelectedFolders()
        if(selectedFolders.count == 1) {
            let folder = selectedFolders.first!.path! as NSString
            selectedPathLbl.stringValue = "\(folder.stringByAbbreviatingWithTildeInPath)"
        } else if(selectedFolders.count > 1) {
            selectedPathLbl.stringValue = "\(selectedFolders.count) folders selected"
        } else {
            selectedPathLbl.stringValue = "No folder selected"
        }
    }
    
    private func detectGitIgnores() -> [NSURL: NSURL?] {
        return GitIgnoreDetector.instance.detect(selectedFolders)
    }
    
    private func showCurrentGitIgnoreValues(ignoreDict : [NSURL: NSURL?]) {
        let gitIgnoreFilePaths = Array(ignoreDict.values.filter { $0 != nil })
        var outputVal = "[No .gitignore detected]"
        if gitIgnoreFilePaths.count == 1 {
            outputVal = "1 .gitignore detected"
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
