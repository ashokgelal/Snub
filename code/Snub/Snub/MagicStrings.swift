//
//  MagicStrings.swift
//  Snub
//
//  Created by Ashok Gelal on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class MagicStrings {
    static let GITIGNORE_MATCH_PATTERN = "#+===#+(\\S+)#+===#+"
    static let GITIGNORE_EXTENSION = ".gitignore"
    static let MASTER_GITIGNORE_NAME = "gitignore-master"
    static let APPNAME = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
}