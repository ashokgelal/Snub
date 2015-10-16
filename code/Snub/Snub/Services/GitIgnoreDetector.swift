//
//  GitIgnoreDetector.swift
//  Snub
//
//  Created by Ashok Gelal on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class GitIgnoreDetector {
    static let instance = GitIgnoreDetector()
    
    private init() {}
    
    func detect(urls: [NSURL]) -> [NSURL:NSURL?] {
        let fm = NSFileManager.defaultManager()
        var retVals: [NSURL:NSURL?] = [:]
        for url in urls {
            do {
                let dirContents = try fm.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
                let gitIgnoreUrl = dirContents.filter { $0.lastPathComponent == ".gitignore" }.first
                retVals[url] = gitIgnoreUrl
            } catch let error as NSError {
                DDLogError("Error enumerating directory contents: \(error.localizedDescription)")
            }
        }
        return retVals
    }
}
