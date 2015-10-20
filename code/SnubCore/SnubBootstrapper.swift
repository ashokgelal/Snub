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

