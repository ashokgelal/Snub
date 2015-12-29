//
//  VisualStudioProjectDetector.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 Ashok Gelal. All rights reserved.
//

class VisualStudioProjectDetector: ProjectTypeDetector {
    func detect(fileExtensions: [String]) -> ProjectDetectionResult? {
        let knownExtensions = ["vs", "sln", "csproj"]
        let detectedTypes = fileExtensions.filter { return knownExtensions.contains($0) }
        if detectedTypes.count > 0 {
            logx.info("Detected \(detectedTypes.count) Visual Studio project type")
            return ProjectDetectionResult(id: "VisualStudio", name: "Visual Studio", confidencePercent: Double(detectedTypes.count) * 100.0/Double(knownExtensions.count))
        }
        return nil
    }
}
