//
//  TextMateProjectDetector.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

class TextMateProjectDetector: ProjectTypeDetector {
    func detect(fileExtensions: [String]) -> ProjectDetectionResult? {
        let knownExtensions = ["tmproj", "tmproject"]
        let detectedTypes = fileExtensions.filter { return knownExtensions.contains($0) }
        if detectedTypes.count > 0 {
            DDLogVerbose("Detected \(detectedTypes.count) TextMate project type")
            return ProjectDetectionResult(projectType: "TextMate", confidencePercent: Double(detectedTypes.count) * 100.0/Double(knownExtensions.count))
        }
        return nil
    }
}