//
//  GitIgnoreTypeDetector.swift
//  Snub
//
//  Created by Ashok Gelal on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import SwiftRegExp

public class GitIgnoreTypeDetector {
    public static let instance = GitIgnoreTypeDetector()
    
    private init() {}
    
    public func detect(urls: [NSURL]) throws -> [NSURL:NSURL?] {
        let fm = NSFileManager.defaultManager()
        var retVals: [NSURL:NSURL?] = [:]
        try urls.forEach {
            url in
            let dirContents = try fm.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            let gitIgnoreUrl = dirContents.filter { $0.lastPathComponent == MagicStrings.GITIGNORE_EXTENSION }.first
            retVals[url] = gitIgnoreUrl
        }
        return retVals
    }
    
    public func identify(url: NSURL) throws -> [String] {
        let contents = try String(contentsOfFile: url.path!)
        if let regexp = try RegExp(pattern: MagicStrings.GITIGNORE_MATCH_PATTERN, options: NSRegularExpressionOptions()) {
            let matches = regexp.allMatches(contents).enumerate() // returns something like ["#===xcode===#", "xcode"]
            return matches.filter { (idx, _) in idx % 2 == 1 }.map { $1 } // extract every other string
        }
        return []
    }
}
