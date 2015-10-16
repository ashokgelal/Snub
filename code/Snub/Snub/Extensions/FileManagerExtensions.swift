//
//  FileManagerExtensions.swift
//  Snub
//
//  Created by Rachana Acharya on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

extension NSFileManager {
    func checkIfDirectoryExists(path: String) -> Bool {
        let fm = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        let fileExists = fm.fileExistsAtPath(path, isDirectory: &isDir)
        return fileExists && isDir
    }
}
