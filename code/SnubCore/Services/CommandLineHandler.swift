//
//  CommandLineHandler.swift
//  SnubCore
//
//  Created by Ashok Gelal on 10/19/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import CommandLine

class CommandLineHandler {
    static let sharedInstance = CommandLineHandler()
    private init() {}
    
    func handle() {
        let args = NSProcessInfo.processInfo().arguments
        let cli = CommandLine(arguments: args)
        let listOption = BoolOption(shortFlag: "l", longFlag: "list", helpMessage: "Lists all available .gitignore files.")
        let suggestOption = BoolOption(shortFlag: "s", longFlag: "suggest", helpMessage: "Suggests an appropriate .gitignore type.")
        let createOption = StringOption(shortFlag: "c", longFlag: "create", helpMessage: "Creates a .gitignore. Backs up any existing .gitignore file.")
        let appendOption = StringOption(shortFlag: "a", longFlag: "append", helpMessage: "Appends to the current .gitignore file if it already exists. Otherwise creates a new .gitignore file.")
        let printOption = StringOption(shortFlag: "p", longFlag: "print", helpMessage: "Prints a .gitignore file.")
        let targetOption = StringOption(shortFlag: "t", longFlag: "target", helpMessage: "Target/Destination directory. If not provided, uses current directory.")
        let luckyOption = BoolOption(shortFlag: "y", longFlag: "lucky", helpMessage: "🍀 Feeling lucky? Adds the most appropriate .gitignore if possible.")
        let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints this help message.")
        let versionOption = BoolOption(shortFlag: "v", longFlag: "version", helpMessage: "Snub version info.")
        cli.addOptions(listOption, suggestOption, createOption, appendOption, printOption, targetOption, luckyOption, versionOption, helpOption)
        
        do {
            if args.count == 2 {
                let arg = args[1]
                if let path=seeIfArgumentIsAPath(arg) {
                    try handleSuggestion(path, true)
                    print("Try -h for help")
                    return
                }
            }
            
            guard args.count > 1 else {
                cli.printUsage()
                return
            }
            
            try cli.parse(true)
            
            if handleHelp(helpOption, cli) { return }
            if handleList(listOption) { return }
            if try handlePrint(printOption) { return }
            
            guard let destination = getTargetDirectory(targetOption) else {
                print(ANSIColors.red + "Invalid target directory \(targetOption.value!)")
                return
            }
            
            if try handleSuggestion(destination, suggestOption.value) { return }
            if try handleLucky(destination, luckyOption.value) { return }
            
            try handleCreate(destination, createOption)
            try handleAppend(destination, appendOption)
            
        } catch {
            cli.printUsage()
        }
    }
    
    private func handleHelp(helpOption: BoolOption, _ cli: CommandLine) -> Bool {
        if helpOption.value {
            cli.printUsage()
            return true
        }
        return false
    }
    
    private func handleList(listOption: BoolOption) -> Bool {
        if listOption.value {
            let allItems = GitIgnoreFileManager.sharedInstance.fetchMasterGitIgnoreItems().map { $0.name }.joinWithSeparator(", ")
            print(allItems)
            return true
        }
        return false
    }
    
    private func seeIfArgumentIsAPath(arg: String) -> NSURL? {
        let fm = NSFileManager.defaultManager()
        if fm.checkIfDirectoryExists(arg) {
            return NSURL(fileURLWithPath: arg)
        }
        let argCouldBeFolder = fm.currentDirectoryPath.appendPathComponent(arg)
        if fm.checkIfDirectoryExists(argCouldBeFolder) {
            return NSURL(fileURLWithPath: argCouldBeFolder)
        }
        return nil
    }
    
    private func handleLucky(destination: NSURL, _ luckyOption: Bool) throws -> Bool {
        if luckyOption {
            let result = try ProjectDetector.sharedInstance.identify(destination)
            if result.count == 0 {
                print(ANSIColors.red + "\(destination.lastPathComponent!) is not so lucky. Snub couldn't suggest any .gitignore")
            } else {
                var suggestions = result.map { $0.id }
                let joinedSuggestion = suggestions.joinWithSeparator("+")
                
                // add first .gitignore
                let outputPath = try GitIgnoreFileManager.sharedInstance.addGitIgnoreWithId(suggestions.first!, toPath: destination)
                suggestions.removeFirst()
                
                // then append the rest
                try suggestions.forEach {
                    try GitIgnoreFileManager.sharedInstance.appendGitIgnoreWithId($0, toPath: destination)
                }
                print(ANSIColors.green + "Snub suggested \(joinedSuggestion)")
                print(ANSIColors.green + "Snub added \(outputPath) for you")
            }
            return true
        }
        return false
    }
    
    private func handleSuggestion(destination: NSURL, _ suggestOption: Bool) throws -> Bool {
        if suggestOption {
            let result = try ProjectDetector.sharedInstance.identify(destination)
            if result.count == 0 {
                print(ANSIColors.red + "Snub couldn't suggest any .gitignore for \(destination.lastPathComponent!) directory")
            } else {
                let suggestions = result.map { $0.id }.joinWithSeparator("+")
                print(ANSIColors.green + "Snub suggests \(suggestions)")
            }
            return true
        }
        return false
    }
    
    private func handleCreate(destination: NSURL, _ createOption: StringOption) throws {
        if let id = createOption.value {
            do {
                let outputPath = try GitIgnoreFileManager.sharedInstance.addGitIgnoreWithId(id, toPath: destination)
                print(ANSIColors.green + "Snub successfully created the following file for you")
                print(outputPath.stringByAbbreviatingWithTildeInPath())
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                print(ANSIColors.red + "Snub couldn't create a .gitignore for you. \(id) gitignore type doesn't exist")
            }
        }
    }
    
    private func handleAppend(destination: NSURL, _ appendOption: StringOption) throws {
        if let id = appendOption.value {
            do {
                try GitIgnoreFileManager.sharedInstance.appendGitIgnoreWithId(id, toPath: destination)
                print(ANSIColors.green + "Snub successfully appended \(id) gitignore for your")
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                print(ANSIColors.red + "Snub couldn't append this gitignore type for you. \(id) gitignore type doesn't exist")
            }
        }
    }
    
    private func handlePrint(printOption: StringOption) throws -> Bool {
        if let id = printOption.value {
            do {
                let contents = try GitIgnoreFileManager.sharedInstance.getGitIgnoreContentsForId(id)
                print(ANSIColors.green + contents)
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                print(ANSIColors.red + "\(id) gitignore type doesn't exist")
            }
            return true
        }
        return false
    }
    
    private func getTargetDirectory(option: StringOption) -> NSURL? {
        var path: String = ""
        if let dest = option.value {
            path = dest
        } else {
            path = NSFileManager.defaultManager().currentDirectoryPath
        }
        if NSFileManager.defaultManager().checkIfDirectoryExists(path) {
            return NSURL(fileURLWithPath: path)
        }
        return nil
    }
}