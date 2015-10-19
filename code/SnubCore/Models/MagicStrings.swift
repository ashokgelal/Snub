//
//  MagicStrings.swift
//  Snub
//
//  Created by Ashok Gelal on 10/16/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

public class MagicStrings {
    public static let GITIGNORE_MATCH_PATTERN = "#+===#+(\\S+)#+===#+"
    public static let GITIGNORE_EXTENSION = ".gitignore"
    public static let GITIGNORE_BACKUP_NAME = "Snub.OldBackup"
    public static let MASTER_GITIGNORE_NAME = "gitignore-master"
    public static let APPNAME = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
    
    static func createGitIgnoreFileHeaderBrand(gitIgnoreType: String) -> String {
       return "# Snub created this #===#\(gitIgnoreType)#===# .gitignore file"
    }
}