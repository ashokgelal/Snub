//
//  CommandLineHandler.swift
//  SnubCore
//
//  Created by Ashok Gelal on 10/19/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

class CommandHandler {
    static let sharedInstance = CommandHandler()
    private init() {}
    private let TAB = "    "
    
    func run() {
        let args = NSProcessInfo.processInfo().arguments
        
        if(handleHelp(args)) { return }
        if(handleVersion(args)) { return }
        if(handleList(args)) { return }
        do {
            if(try handleSuggest(args)) { return }
            if(try handleLucky(args)) { return }
            if(try handleAdd(args)) { return }
            if(try handleAppend(args)) { return }
        } catch {
            printHelp()
        }
        printHelp()
    }
    
    private func seeIfArgumentIsAPath(arg: String?) -> NSURL? {
        guard let path = arg else {
            return nil
        }
        let fm = NSFileManager.defaultManager()
        if fm.checkIfDirectoryExists(path) {
            return NSURL(fileURLWithPath: path)
        }
        let argCouldBeFolder = fm.currentDirectoryPath.appendPathComponent(path)
        if fm.checkIfDirectoryExists(argCouldBeFolder) {
            return NSURL(fileURLWithPath: argCouldBeFolder)
        }
        return nil
    }
    
    private func handleVersion(args: [String]) -> Bool {
        if args.count >= 2 && (args[1] == "-v" || args[1] == "--version") {
            print(Format.green + "Snub \(MagicStrings.COMMANDLINE_VERSION) (Licensed to hellornaapps@gmail.com)")
            return true
        }
        return false
    }
    
    private func handleList(args: [String]) -> Bool {
        if args.count >= 2 && args[1] == "list" {
            let allItems = GitIgnoreFileManager.sharedInstance.fetchMasterGitIgnoreItems().map { $0.name }.joinWithSeparator(", ")
            print(allItems)
            return true
        }
        return false
    }
}

// MARK: Add
extension CommandHandler {
    private func handleAdd(args: [String]) throws -> Bool {
        guard args[1] == "add" else {
            return false
        }
        
        guard args.count > 3 else {
            printAddHelp()
            return true
        }
        
        guard let url = seeIfArgumentIsAPath(args[3]) else {
            print(Format.red + "Invalid target directory: \(args[3])")
            return false
        }
        
        var ids = args[2].characters.split { $0 == "+" }.map(String.init)
        do {
            try GitIgnoreFileManager.sharedInstance.addGitIgnoreWithId(ids[0], toPath: url)
            print(Format.green + "Successfully added '\(ids[0])' gitignore type")
        } catch GitIgnoreError.SourceGitIgnoreNotFound {
            print(Format.red + "Snub couldn't add a '\(ids[0])'. The gitignore type doesn't exist")
            return true
        }
        
        ids.removeFirst()
        try ids.forEach {
            id in
            do {
                // first add then append
                try GitIgnoreFileManager.sharedInstance.appendGitIgnoreWithId(id, toPath: url)
                print(Format.green + "Successfully appended '\(id)' gitignore type")
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                print(Format.red + "Snub couldn't append a '\(id)'. The gitignore type doesn't exist")
            }
        }
        return true
    }
    
    private func printAddHelp() {
        print(Format.red + "[!] At least 1 gitignore type and a target directory is required")
        print("")
        print(Format.bold + "Usage:")
        print("")
        print("\(TAB)$ snub add " + (Format.red+"<TYPE1+TYPE2+...> TARGET_DIRECTORY"))
        print("")
        print("\(TAB)  Adds one or more .gitignore files of" + (Format.red + " `TYPE` ") + "to the given" + (Format.red + " `TARGET_DIRECTORY`") + ".")
        print("\(TAB)  If a .gitignore file already exists in the `TARGET_DIRECTORY`, it will be renamed ")
        print("\(TAB)  to `\(MagicStrings.GITIGNORE_BACKUP_NAME).gitignore`.")
        print("")
        print("\(TAB)  To add more than 1 type of .gitignore files, separate them using a `+`")
        print("\(TAB)  such as `Xcode+OSX`.")
    }
}

// MARK: Append
extension CommandHandler {
    private func handleAppend(args: [String]) throws -> Bool {
        guard args[1] == "append" else {
            return false
        }
        
        guard args.count > 3 else {
            printAppendHelp()
            return true
        }
        
        guard let url = seeIfArgumentIsAPath(args[3]) else {
            print(Format.red + "Invalid target directory: \(args[3])")
            return false
        }
        
        let ids = args[2].characters.split { $0 == "+" }.map(String.init)
        try ids.forEach {
            id in
            do {
                try GitIgnoreFileManager.sharedInstance.appendGitIgnoreWithId(id, toPath: url)
                print(Format.green + "Successfully appended '\(id)' gitignore type")
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                print(Format.red + "Snub couldn't append a '\(id)'. The gitignore type doesn't exist")
            }
        }
        return true
    }
    
    private func printAppendHelp() {
        print(Format.red + "[!] At least 1 gitignore type and a target directory is required")
        print("")
        print(Format.bold + "Usage:")
        print("")
        print("\(TAB)$ snub append " + (Format.red+"<TYPE1+TYPE2+...> TARGET_DIRECTORY"))
        print("")
        print("\(TAB)  Appends one or more .gitignore files of" + (Format.red + " `TYPE` ") + "to the given" + (Format.red + " `TARGET_DIRECTORY`") + ".")
        print("\(TAB)  If a .gitignore file doesn't already exist in the `TARGET_DIRECTORY`, it will")
        print("\(TAB)  be created.")
        print("")
        print("\(TAB)  To append more than 1 type of .gitignore files, separate them using a `+`")
        print("\(TAB)  such as `Xcode+OSX`.")
    }
}

// MARK: Suggest
extension CommandHandler {
    private func handleLucky(args: [String]) throws -> Bool {
        guard args[1] == "lucky" else {
            return false
        }
        guard args.count == 3 else {
            print(Format.red + "[!] A target directory is required")
            print("")
            print(Format.bold + "Usage:")
            print("")
            print("\(TAB)$ snub lucky " + (Format.red+"TARGET_DIRECTORY"))
            print("")
            print("\(TAB)  If possible, adds one or more appropriate .gitignore files for the given" + (Format.red + " `TARGET_DIRECTORY`") + ".")
            print("\(TAB)  Feeling lucky? 🍀")
            return true
        }
        
        guard let url = seeIfArgumentIsAPath(args[2]) else {
            print(Format.red + "Invalid target directory: \(args[2])")
            return false
        }
        
        var suggestions = try ProjectDetector.sharedInstance.identify(url).map { $0.id }
        if suggestions.count == 0 {
            print(Format.red + "Not so lucky! Snub couldn't suggest any .gitignore files for `\(url.lastPathComponent!)` directory")
            return true
        }
        
        let joinedSuggestion = suggestions.joinWithSeparator("+")
        
        // add first .gitignore
        let outputPath = try GitIgnoreFileManager.sharedInstance.addGitIgnoreWithId(suggestions.first!, toPath: url)
        suggestions.removeFirst()
        
        // then append the rest
        try suggestions.forEach {
            try GitIgnoreFileManager.sharedInstance.appendGitIgnoreWithId($0, toPath: url)
        }
        print(Format.green + "Snub suggested \(joinedSuggestion)")
        print(Format.green + "Snub added \(outputPath) for you")
        return true
    }
}

// MARK: Suggest
extension CommandHandler {
    private func handleSuggest(args: [String]) throws -> Bool {
        guard args[1] == "suggest" else {
            return false
        }
        
        guard args.count == 3 else {
            print(Format.red + "[!] A target directory is required")
            print("")
            print(Format.bold + "Usage:")
            print("")
            print("\(TAB)$ snub suggest " + (Format.red+"TARGET_DIRECTORY"))
            print("")
            print("\(TAB)  Suggests one or more appropriate .gitignore files for the given" + (Format.red + " `TARGET_DIRECTORY`") + ".")
            return true
        }
        
        guard let url = seeIfArgumentIsAPath(args[2]) else {
            print(Format.red + "Invalid target directory: \(args[2])")
            return false
        }
        
        let result = try ProjectDetector.sharedInstance.identify(url)
        if result.count == 0 {
            print(Format.red + "Snub couldn't suggest any .gitignore files for `\(url.lastPathComponent!)` directory")
        } else {
            let suggestions = result.map { $0.id }.joinWithSeparator("+")
            print(Format.green + "Snub suggests \(suggestions)")
        }
        return true
    }
}

// MARK: Help
extension CommandHandler {
    private func handleHelp(args: [String]) -> Bool {
        if args.count == 1 {
            printHelp()
            return true
        }
        if args.count >= 2 && (args[1] == "-h" || args[1] == "--help") {
            printHelp()
            return true
        }
        return false
    }
    
    private func printHelp() {
        //        printLogo()
        print("")
        printUsage()
        print("")
        printCommands()
        print("")
        printOptions()
        print("")
    }
    
    private func printLogo() {
        print("                 _       ")
        print(" ___ _ __  _   _| |__    ")
        print("/ __| '_ \\| | | | '_ \\ ")
        print("\\__ \\ | | | |_| | |_) |")
        print("|___/_| |_|\\__,_|_.__/  ")
        print("")
        print("Adding .gitignore files doesn't get any easier than this")
    }
    
    private func printUsage() {
        print(Format.bold + "Usage:")
        print("")
        print("\(TAB)$ snub COMMAND")
    }
    
    private func printCommands() {
        print(Format.bold + "Commands:")
        print("")
        
        print(makeCommand("list"))
        print(makeCommand("add") + " <type1+type2+...> [target]   " + makeExample("snub add xcode+osx ."))
        print(makeCommand("append") + " <type1+type2+...> [target]" + makeExample("snub append xcode+osx ."))
        print(makeCommand("print") + " <type1+type2+...>          " + makeExample("snub print xcode+osx"))
        print(makeCommand("suggest") + " [target]")
        print(makeCommand("lucky") + " [target]")
        print(makeCommand("help") + " <command>                   " + makeExample("snub help add"))
    }
    
    private func printOptions() {
        print(Format.bold + "Options:")
        print("")
        
        print(makeOption("(-v | --version)") + makeSuffix("Show the version and licensing info"))
        print(makeOption("(-h | --help)   ") + makeSuffix("Print this help"))
    }
    
    private func makeCommand(text: String) -> String {
        return Format.green + "\(TAB)+ \(text)"
    }
    
    private func makeOption(text: String) -> String {
        return Format.magenta + "\(TAB)\(text)"
    }
    
    private func makeExample(text: String) -> String {
        return Format.darkGray + "\(TAB)\(TAB)E.g. $ \(text)"
    }
    
    private func makeSuffix(text: String) -> String {
        return Format.darkGray + "\(TAB)\(TAB)\(text)"
    }
}