//
//  SuggestedTabViewItemController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import AsyncSwift
import SnubCore

class SuggestedTabViewItemController: MasterGitIgnoreTabViewItemController {
    override func loadSelectedFolders(selectedFolders: [NSURL]) {
        self.selectedFolders = selectedFolders
        var items: [GitIgnoreFileItem] = []
        progressIndicator.startAnimation(self)
        Async.background { [unowned self] in
            items = self.determineSuggestedProjectTypes(selectedFolders)
        }.main { [unowned self] in
            self.gitIgnoreItems = items
        }
    }
    
    private func determineSuggestedProjectTypes(selectedFolders : [NSURL]) -> [GitIgnoreFileItem] {
        var outputVal = "[Couldn't determine project type]"
        var items: [GitIgnoreFileItem] = []
        if selectedFolders.count == 1 {
            do {
                items = try ProjectDetector.sharedInstance.identify(selectedFolders.first!)
                if(items.count > 0) {
                    outputVal = "Was able to determine project types"
                }
            } catch let error as NSError {
                logx.warning("Error identifying: \(error.localizedDescription)")
            }
        } else if selectedFolders.count > 1 {
            outputVal = "Snub suggestion only works with 1 selected project"
        }
        logx.info(outputVal)
        return items
    }
}

