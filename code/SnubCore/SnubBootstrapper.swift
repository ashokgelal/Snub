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

public class BootStrapper {
    
    public init() {
    }
    
    private func setupLogger(){
//        defaultDebugLevel = DDLogLevel.Verbose
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDTTYLogger.sharedInstance().colorsEnabled = true
    }
    
    public func setup() {
        Async.background { GitIgnoreFileManager.instance }
        setupLogger()
    }
}