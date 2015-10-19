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
        let printFile = BoolOption(shortFlag: "p", longFlag: "print", helpMessage: "Prints a .gitignore file.")
        let directory = StringOption(shortFlag: "d", longFlag: "directory", helpMessage: "Target/Destination directory. If not provided, uses current directory.")
        let lucky = BoolOption(shortFlag: "🍀", longFlag: "lucky", helpMessage: "Feeling lucky? Adds the most appropriate .gitignore if possible.")
        let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints this help message.")
        cli.addOptions(list, suggest, create, append, printFile, directory, lucky, help)
        
        guard args.count > 1 else {
            cli.printUsage()
            return
        }
        
        do {
            try cli.parse()
            if help.value {
                cli.printUsage()
                return
            }
            if list.value {
                let allItems = GitIgnoreFileManager.sharedInstance.fetchMasterGitIgnoreItems().map { $0.name }.joinWithSeparator(", ")
                print(allItems)
                return
            }
            if create.wasSet {
                print("Create: \(create.value)")
            }
            
            if args.count == 2 && args[1] == "." {
            }
        } catch {
            cli.printUsage()
        }
    }
}