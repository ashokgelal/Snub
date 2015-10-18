//
//  GitIgnoreFileFinder.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

class GitIgnoreFileFinder {
    static let instance = GitIgnoreFileFinder()
    private init(){}
    private lazy var masterGitIgnoreFiles: [String] = {
        let fm = NSFileManager.defaultManager()
        let gitIgnoreMasterDir = fm.getApplicationDirectoryPath().appendPathComponent(MagicStrings.MASTER_GITIGNORE_NAME)
        do {
            return try fm.subpathsOfDirectoryAtPath(gitIgnoreMasterDir)
        } catch { return [] } }()
    
    func findById(id: String) -> String? {
        let fm = NSFileManager.defaultManager()
        let gitIgnoreMasterDir = fm.getApplicationDirectoryPath().appendPathComponent(MagicStrings.MASTER_GITIGNORE_NAME)
        for file in masterGitIgnoreFiles {
            if (file.fileName() == id) {
                return gitIgnoreMasterDir.appendPathComponent(file)
            }
        }
        return nil
    }
}