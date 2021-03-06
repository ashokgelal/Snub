//
//  JetBrainsProjectDetector.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

class JetBrainsProjectDetector: ProjectTypeDetector {
    func detect(fileExtensions: [String]) -> ProjectDetectionResult? {
        let knownExtensions = ["iml", "idea", "idea_modules"]
        let detectedTypes = fileExtensions.filter { return knownExtensions.contains($0) }
        if detectedTypes.count > 0 {
            logx.info("Detected JetBrains/IntelliJ project type \(detectedTypes.count)")
            return ProjectDetectionResult(id: "JetBrains", name: "JetBrains/IntelliJ", confidencePercent: Double(detectedTypes.count) * 100.0/Double(knownExtensions.count))
        }
        return nil
    }
}
