//
//  FinderSelectionProvider.swift
//  Snub
//
//  Created by Ashok Gelal on 10/14/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import ScriptingBridge

class FinderSelectionProvider {
    
    class var instance: FinderSelectionProvider {
        struct Singleton {
            private static let instance = FinderSelectionProvider()
        }
        return Singleton.instance
    }
    
    private init(){}
    
    func getSelectedFolders() -> [NSURL] {
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
            var isDir: ObjCBool = false
            let fileExists = fm.fileExistsAtPath(url.path!, isDirectory: &isDir)
            return fileExists && isDir
        }.map { return NSURL(string: $0 as! String)!}
    }
}