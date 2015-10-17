//
//  ProjectDetectionResult.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//


struct ProjectDetectionResult {
    let projectType: String
    let confidencePercent: Double
    init(projectType: String, confidencePercent: Double) {
        self.projectType = projectType
        self.confidencePercent = confidencePercent
    }
}
