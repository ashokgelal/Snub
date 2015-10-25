//
//  LicenseInfo.swift
//  SnubCore
//
//  Created by Ashok Gelal on 10/25/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

public class LicenseInfo: NSObject {
    public let key: String!
    public let email: String!
    let lastCheckedDate: NSDate?
   
    convenience init(key: String, email: String) {
        self.init(key: key, email: email, checkedDate: nil)
    }
    
    init(key: String, email: String, checkedDate: NSDate?) {
        self.key = key
        self.email = email
        self.lastCheckedDate = checkedDate
    }
}