//
//  SnubBootstrapper.swift
//  SnubCore
//
//  Created by Ashok Gelal on 10/18/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import LogKit

public var logx = LXLogger(endpoints: [LXConsoleEndpoint(synchronous: false, minimumPriorityLevel: .Error)])

@objc public class Bootstrapper : NSObject {
    public static let sharedInstance = Bootstrapper()
    
    private override init() { super.init() }
    
    public func setupForUI() {
        logx = LXLogger(endpoints: [LXConsoleEndpoint(synchronous: true, minimumPriorityLevel: .All)])
        logx.info("Setting up Snub for UI");
        do {
            try GitIgnoreFileManager.sharedInstance.setup()
        } catch {
            logx.critical("\(MagicStrings.MASTER_GITIGNORE_NAME).zip file is missing.")
        }
    }
    
    public func setupForCommandLine() {
        logx = LXLogger(endpoints: [LXConsoleEndpoint(synchronous: false, minimumPriorityLevel: .Error)])
        logx.info("Setting up Snub for Command");
        do {
            try GitIgnoreFileManager.sharedInstance.setup()
            CommandHandler.sharedInstance.run()
        } catch {
            logx.critical("\(MagicStrings.MASTER_GITIGNORE_NAME).zip file is missing.\nMake sure to run the UI at least once.")
        }
    }
}
