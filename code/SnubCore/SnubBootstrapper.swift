//
//  SnubBootstrapper.swift
//  SnubCore
//
//  Created by Ashok Gelal on 10/18/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Async
import CommandLine
import Commander

@objc public class Bootstrapper : NSObject {
    public static let sharedInstance = Bootstrapper()
    
    private override init() {
        super.init()
        setupLogger()
    }
    
    private func setupLogger(){
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDTTYLogger.sharedInstance().colorsEnabled = true
    }
    
    public func setupForUI() {
        defaultDebugLevel = DDLogLevel.Verbose
        DDLogVerbose("Setting up Snub for UI");
        Async.background { GitIgnoreFileManager.sharedInstance }
    }
    
    public func setupForCommandLine() {
        defaultDebugLevel = DDLogLevel.Error
        DDLogVerbose("Setting up Snub for Command");
        GitIgnoreFileManager.sharedInstance
        CommandLineHandler.sharedInstance.handle()
    }
}

enum Operation: String {
    case Create  = "c"
    case Extract = "x"
    case List    = "l"
    case Verify  = "v"
}

class CommandLineHandler {
    static let sharedInstance = CommandLineHandler()
    private init() {}
    
    func handle() {
        let args = NSProcessInfo.processInfo().arguments
        let cli = CommandLine(arguments: args)
        let list = BoolOption(shortFlag: "l", longFlag: "list", helpMessage: "Lists all available .gitignore files.")
        let suggest = BoolOption(shortFlag: "s", longFlag: "suggest", helpMessage: "Suggests an appropriate .gitignore type.")
        let create = StringOption(shortFlag: "c", longFlag: "create", helpMessage: "Creates a .gitignore. Backs up any existing .gitignore file.")
        let append = StringOption(shortFlag: "a", longFlag: "append", helpMessage: "Appends to the current .gitignore file if it already exists. Otherwise creates a new .gitignore file.")
        let printOption = StringOption(shortFlag: "p", longFlag: "print", helpMessage: "Prints a .gitignore file.")
        let target = StringOption(shortFlag: "t", longFlag: "target", helpMessage: "Target/Destination directory. If not provided, uses current directory.")
        let lucky = BoolOption(shortFlag: "🍀", longFlag: "lucky", helpMessage: "Feeling lucky? Adds the most appropriate .gitignore if possible.")
        let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints this help message.")
        cli.addOptions(list, suggest, create, append, printOption, target, lucky, help)
        
        do {
            if args.count == 1 {
                try handleSuggestion(NSURL(fileURLWithPath: "."), true)
                print("Try -h for help")
                return
            }
            
            guard args.count > 1 else {
                cli.printUsage()
                return
            }
        
            try cli.parse(true)
            
            guard let destination = getTargetDirectory(target) else {
                print(ANSIColors.red + "Invalid target directory \(target.value!)")
                return
            }
            
            if help.value {
                cli.printUsage()
                return
            }
            
            if list.value {
                let allItems = GitIgnoreFileManager.sharedInstance.fetchMasterGitIgnoreItems().map { $0.name }.joinWithSeparator(", ")
                print(allItems)
                return
            }
            
            if try handlePrint(printOption) {
                return
            }
            
            if try handleSuggestion(destination, suggest.value) {
                return
            }
            
            try handleCreate(destination, create)
            
        } catch {
            cli.printUsage()
        }
    }
    
    private func handleSuggestion(_ destination: NSURL, _ suggest: Bool) throws -> Bool {
        if suggest {
            let result = try ProjectDetector.sharedInstance.identify(destination)
            if result.count == 0 {
                print(ANSIColors.red + "Snub couldn't suggest any .gitignore for \(destination.lastPathComponent!) directory")
            } else {
                let suggestions = result.map { $0.id }.joinWithSeparator("+")
                print(ANSIColors.green + "Snub suggests: \(suggestions)")
            }
            return true
        }
        return false
    }
    
    private func handleCreate(_ destination: NSURL, _ create: StringOption) throws {
        if let id = create.value {
            do {
                let outputPath = try GitIgnoreFileManager.sharedInstance.addGitIgnoreWithId(id, toPath: destination)
                print(ANSIColors.green + "Snub successfully created the following file for you")
                print(outputPath.stringByAbbreviatingWithTildeInPath())
            } catch GitIgnoreError.SourceGitIgnoreNotFound {
                print(ANSIColors.red + "Snub couldn't create a .gitignore for you. \(id) gitignore type doesn't exist")
            }
        }
    }
    
    private func handlePrint(_ printOption: StringOption) throws -> Bool {
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