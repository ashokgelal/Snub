//
//  Enums.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

public enum GitIgnoreError: ErrorType {
    case SourceGitIgnoreNotFound
    case GitIgnoreMasterNotFound
}

public enum LicenseError: ErrorType {
    case LicenseFileNotFound
    case LicenseCorrupted
    case ErrorReadingLicenseFileContents
}

enum Format: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[1;37m"
    case darkGray = "\u{001B}[0;37m"
    case bold = "\u{001B}[1m"
}

func + (let left: Format, let right: String) -> String {
    return left.rawValue + right + "\u{001B}[0m"
}