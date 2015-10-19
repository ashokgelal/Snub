//
//  MagicStrings.swift
//  Snub
//
//  Created by Ashok Gelal on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

class MagicStrings {
    static let GITIGNORE_MATCH_PATTERN = "#+===#+(\\S+)#+===#+"
    static let GITIGNORE_EXTENSION = ".gitignore"
    static let GITIGNORE_BACKUP_NAME = "Snub.OldBackup"
    static let MASTER_GITIGNORE_NAME = "gitignore-master"
    static let APPNAME = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
    
    static func createGitIgnoreFileHeaderBrand(gitIgnoreType: String) -> String {
       return "# Snub created this #===#\(gitIgnoreType)#===# .gitignore file"
    }
}