//
//  Enums.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

public enum GitIgnoreError: ErrorType {
    case SourceGitIgnoreNotFound
}

enum ANSIColors: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    
    func name() -> String {
        switch self {
        case black: return "Black"
        case red: return "Red"
        case green: return "Green"
        case yellow: return "Yellow"
        case blue: return "Blue"
        case magenta: return "Magenta"
        case cyan: return "Cyan"
        case white: return "White"
        }
    }
    
    static func all() -> [ANSIColors] {
        return [.black, .red, .green, .yellow, .blue, .magenta, .cyan, .white]
    }
}

func + (let left: ANSIColors, let right: String) -> String {
    return left.rawValue + right
}