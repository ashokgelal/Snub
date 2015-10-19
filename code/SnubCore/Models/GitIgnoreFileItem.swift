//
//  GitIgnoreFileItem.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

public class GitIgnoreFileItem: NSObject {
    public let name: String
    public let id: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
