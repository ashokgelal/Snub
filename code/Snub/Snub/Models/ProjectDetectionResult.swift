//
//  ProjectDetectionResult.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

class ProjectDetectionResult: NSObject {
    let projectType: String
    let confidencePercent: Double
    let id: String
    
    init(id: String, projectType: String, confidencePercent: Double) {
        self.id = id
        self.projectType = projectType
        self.confidencePercent = confidencePercent
    }
}
