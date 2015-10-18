//
//  SuggestedTabViewItemController.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class SuggestedTabViewItemController: MasterGitIgnoreTabViewItemController {
    
    override var selectedFolders: [NSURL] {
        didSet {
            determineSuggestedProjectTypes(selectedFolders)
        }
    }
    
    private func determineSuggestedProjectTypes(selectedFolders : [NSURL]) {
        var outputVal = "[Couldn't determine project type]"
        if selectedFolders.count == 1 {
            do {
                gitIgnoreItems = try ProjectDetector.instance.identify(selectedFolders.first!)
                if(gitIgnoreItems.count > 0) {
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

