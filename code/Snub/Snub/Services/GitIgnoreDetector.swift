//
//  GitIgnoreDetector.swift
//  Snub
//
//  Created by Ashok Gelal on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import SwiftRegExp

class GitIgnoreDetector {
    static let instance = GitIgnoreDetector()
    
    private init() {}
    
    func detect(urls: [NSURL]) -> [NSURL:NSURL?] {
        let fm = NSFileManager.defaultManager()
        var retVals: [NSURL:NSURL?] = [:]
        for url in urls {
            do {
                let dirContents = try fm.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
                let gitIgnoreUrl = dirContents.filter { $0.lastPathComponent == MagicStrings.GITIGNORE_EXTENSION }.first
                retVals[url] = gitIgnoreUrl
            } catch let error as NSError {
                DDLogError("Error enumerating directory contents: \(error.localizedDescription)")
            }
        }
        return retVals
    }
    
    func identify(url: NSURL) throws -> [String] {
        let contents = try String(contentsOfFile: url.path!)
        if let regexp = try RegExp(pattern: MagicStrings.GITIGNORE_MATCH_PATTERN, options: NSRegularExpressionOptions()) {
            let matches = regexp.allMatches(contents).enumerate() // returns something like ["#===xcode===#", "xcode"]
            return matches.filter { (idx, _) in idx % 2 == 1 }.map { $1 } // extract every other string
        }
        return []
    }
}
