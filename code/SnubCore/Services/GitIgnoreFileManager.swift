//
//  GitIgnoreFileManager.swift
//  Snub
//
//  Created by Rachana Acharya on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import PDKTZipArchive

public class GitIgnoreFileManager {
    public static let sharedInstance = GitIgnoreFileManager()
    
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
                DDLogError("\(MagicStrings.MASTER_GITIGNORE_NAME).zip file is missing.\nIf you are running from command line, make sure to run the UI at least once.")
            }
        }
    }
    
    private func setupApplicationSupportDirectory() -> String {
        let fm = NSFileManager.defaultManager()
        let appDirectoryPath = fm.getApplicationDirectoryPath()
        if(fm.checkIfDirectoryExists(appDirectoryPath)) {
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
    
    public func addGitIgnoreWithId(id: String, toPath: NSURL) throws -> String {
        guard let sourceGitIgnorePath = GitIgnoreFileFinder.instance.findById(id) else {
            throw GitIgnoreError.SourceGitIgnoreNotFound
        }
        
        let path = toPath.path!
        let destinationFullPath = path.appendPathComponent(MagicStrings.GITIGNORE_EXTENSION)
        
        // first backup existing .gitignore
        let fm = NSFileManager.defaultManager()
        if(fm.checkIfFileExists(destinationFullPath)) {
            let backupFilePath = path.appendPathComponent("\(MagicStrings.GITIGNORE_BACKUP_NAME)\(MagicStrings.GITIGNORE_EXTENSION)")
            // remove previous backup file
            if(fm.checkIfFileExists(backupFilePath)) {
                try fm.removeItemAtPath(backupFilePath)
            }
            try fm.moveItemAtPath(destinationFullPath, toPath: backupFilePath)
            DDLogInfo("Found and copied old .gitignore file to \(backupFilePath)")
        }
        
        let netGitIgnoreContents = try String(contentsOfFile: sourceGitIgnorePath)
        let headerBrand = MagicStrings.createGitIgnoreFileHeaderBrand(id)
        
        let contents = "\(headerBrand)\n\(netGitIgnoreContents)"
        try contents.writeToFile(destinationFullPath, atomically: true, encoding: NSUTF8StringEncoding)
        DDLogVerbose("Successfully copied \(id) .gitignore to \(destinationFullPath)")
        return destinationFullPath
    }
    
    public func appendGitIgnoreWithId(id:String, toPath: NSURL) throws -> String {
        guard let sourceGitIgnorePath = GitIgnoreFileFinder.instance.findById(id) else {
            throw GitIgnoreError.SourceGitIgnoreNotFound
        }
        
        let destinationFullPath = toPath.path!.appendPathComponent(MagicStrings.GITIGNORE_EXTENSION)
        let existingGitIgnoreContents = try String(contentsOfFile: destinationFullPath)
        
        let newGitIgnoreContents = try String(contentsOfFile: sourceGitIgnorePath)
        let headerBrand = MagicStrings.createGitIgnoreFileHeaderBrand(id)
        
        let contents = "\(existingGitIgnoreContents)\n\n\(headerBrand)\n\(newGitIgnoreContents)"
        try contents.writeToFile(destinationFullPath, atomically: true, encoding: NSUTF8StringEncoding)
        DDLogVerbose("Successfully appended \(id) .gitignore to \(destinationFullPath)")
        return destinationFullPath
    }
    
    public func getGitIgnoreContentsForId(id:String) throws -> String {
        guard let sourceGitIgnorePath = GitIgnoreFileFinder.instance.findById(id) else {
            throw GitIgnoreError.SourceGitIgnoreNotFound
        }
        
        let newGitIgnoreContents = try String(contentsOfFile: sourceGitIgnorePath)
        let headerBrand = MagicStrings.createGitIgnoreFileHeaderBrand(id)
        
        let contents = "\(headerBrand)\n\(newGitIgnoreContents)"
        return contents
    }
    
    public func fetchMasterGitIgnoreItems() -> [GitIgnoreFileItem] {
        return allGitIgnoreFilePaths.map {
            file -> GitIgnoreFileItem in
            let name = file.path!.fileName()
            return GitIgnoreFileItem(id: name, name: name)
        }
    }
    
    private lazy var allGitIgnoreFilePaths: [NSURL] = {
        let fm = NSFileManager.defaultManager()
        let unzippedPath = fm.getApplicationDirectoryPath().appendPathComponent(MagicStrings.MASTER_GITIGNORE_NAME)
        let enumerator = fm.enumeratorAtPath(unzippedPath)
        var fileURLs:[NSURL] = []
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(MagicStrings.GITIGNORE_EXTENSION) {
                let fullPath = (unzippedPath as NSString).stringByAppendingPathComponent(element)
                fileURLs += [NSURL(fileURLWithPath: fullPath)]
            }
        }
        return fileURLs
    }()
}
