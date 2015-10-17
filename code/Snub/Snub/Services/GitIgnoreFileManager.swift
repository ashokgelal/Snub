//
//  GitIgnoreFileManager.swift
//  Snub
//
//  Created by Rachana Acharya on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa
import PDKTZipArchive

class GitIgnoreFileManager {
    static let instance = GitIgnoreFileManager()
    
    private init() {
        let applicationSupportPath = setupApplicationSupportDirectory()
        let unzippedPath = (applicationSupportPath as NSString).stringByAppendingPathComponent(MagicStrings.MASTER_GITIGNORE_NAME)
        if(NSFileManager.defaultManager().checkIfDirectoryExists(unzippedPath)) {
            DDLogVerbose("\(MagicStrings.MASTER_GITIGNORE_NAME) folder already unzipped")
        }
        else {
            if let url = NSBundle.mainBundle().URLForResource(MagicStrings.MASTER_GITIGNORE_NAME, withExtension: "zip") {
                if(PDKTZipArchive.unzipFileAtPath(url.path, toDestination: applicationSupportPath)) {
                    DDLogVerbose("Successfully unzipped \(MagicStrings.MASTER_GITIGNORE_NAME).zip")
                } else {
                    DDLogError("Cannot unzip \(MagicStrings.MASTER_GITIGNORE_NAME).zip")
                }
            } else {
                DDLogError("\(MagicStrings.MASTER_GITIGNORE_NAME).zip file is missing")
            }
        }
    }
    
    func getAllGitIgnoreFilePaths() -> [NSURL] {
        let fm = NSFileManager.defaultManager()
        let unzippedPath = (getApplicationDirectoryPath() as NSString).stringByAppendingPathComponent(MagicStrings.MASTER_GITIGNORE_NAME)
        let enumerator = fm.enumeratorAtPath(unzippedPath)
        var fileURLs:[NSURL] = []
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(MagicStrings.GITIGNORE_EXTENSION) {
                let fullPath = (unzippedPath as NSString).stringByAppendingPathComponent(element)
                fileURLs += [NSURL(fileURLWithPath: fullPath)]
            }
        }
        return fileURLs
    }
    
    private func setupApplicationSupportDirectory() -> String {
        let appDirectoryPath = getApplicationDirectoryPath()
        if(NSFileManager.defaultManager().checkIfDirectoryExists(appDirectoryPath)) {
            DDLogVerbose("App Support Directory \(appDirectoryPath) already exists")
            return appDirectoryPath
        }
        
        do {
            let fm = NSFileManager.defaultManager()
            try fm.createDirectoryAtPath(appDirectoryPath, withIntermediateDirectories: false, attributes: nil)
            DDLogVerbose("Successfully created App Support Directory \(appDirectoryPath)")
        } catch {
            DDLogError("Cannot create a directory \(appDirectoryPath)")
        }
        return appDirectoryPath
    }
    
    private func getApplicationDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let supportDirectory = paths.first!
        return (supportDirectory as NSString).stringByAppendingPathComponent(MagicStrings.APPNAME)
    }
}
