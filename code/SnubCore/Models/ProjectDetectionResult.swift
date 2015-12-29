//
//  ProjectDetectionResult.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

import Foundation

public class ProjectDetectionResult: GitIgnoreFileItem {
    let confidencePercent: Double
    
    init(id: String, name: String, confidencePercent: Double) {
        self.confidencePercent = confidencePercent
        super.init(id: id, name: name)
    }
}
