//
//  FileManagerExtensions.swift
//  Snub
//
//  Created by Rachana Acharya on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

// MARK: NSFileManager Extensions
extension NSFileManager {
    func checkIfDirectoryExists(path: String) -> Bool {
        let fm = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        let fileExists = fm.fileExistsAtPath(path, isDirectory: &isDir)
        return fileExists && isDir
    }
    
    func checkIfFileExists(path: String) -> Bool {
        let fm = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        let fileExists = fm.fileExistsAtPath(path, isDirectory: &isDir)
        return fileExists && !isDir
    }
    
    func getApplicationDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let supportDirectory = paths.first!
        return (supportDirectory as NSString).stringByAppendingPathComponent(MagicStrings.APPNAME)
    }
}

// MARK: String Extensions
extension String {
    func fileName() -> String {
        return ((self as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
    }
    
    func fileExtension() -> String {
        return (self as NSString).pathExtension
    }
    
    func appendPathComponent(suffix: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(suffix)
    }
}

// MARK: Thread Functions
func delay(delay: Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
