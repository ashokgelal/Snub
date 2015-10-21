//
//  FinderSelectionProvider.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import ScriptingBridge
import CocoaLumberjack

public class FinderSelectionProvider {
    
    public static let instance = FinderSelectionProvider()
    
    private init(){}
    
    public func getSelectedFolders() -> [NSURL] {
        guard let finder = SBApplication(bundleIdentifier: "com.apple.finder") as? FinderApplication,
            let result = finder.selection else {
                DDLogInfo("No items selected")
                return []
        }
        guard let selection = result.get() else {
            DDLogInfo("No items selected")
            return []
        }
        
        let items = selection.arrayByApplyingSelector(Selector("URL"))
        let fm = NSFileManager.defaultManager()
        return items.filter {
            item -> Bool in
            let url = NSURL(string: item as! String)!
            return fm.checkIfDirectoryExists(url.path!)
        }.map { return NSURL(string: $0 as! String)!}
    }
}