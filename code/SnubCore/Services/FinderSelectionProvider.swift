//
//  FinderSelectionProvider.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

import Foundation
import ScriptingBridge

public class FinderSelectionProvider {
    
    public static let instance = FinderSelectionProvider()
    
    private init(){}
    
    public func getSelectedFolders() -> [NSURL] {
        guard let finder = SBApplication(bundleIdentifier: "com.apple.finder") as? FinderApplication,
            let result = finder.selection else {
                logx.info("No items selected")
                return []
        }
        guard let selection = result.get() else {
            logx.info("No items selected")
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