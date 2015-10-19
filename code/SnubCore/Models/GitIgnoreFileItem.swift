//
//  GitIgnoreFileItem.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

class GitIgnoreFileItem: NSObject {
    let name: String
    let id: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
