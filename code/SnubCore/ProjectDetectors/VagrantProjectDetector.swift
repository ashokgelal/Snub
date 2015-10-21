//
//  VagrantProjectDetector.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import CocoaLumberjack

class VagrantProjectDetector: ProjectTypeDetector {
    func detect(fileExtensions: [String]) -> ProjectDetectionResult? {
        let knownExtensions = ["vagrant"]
        let detectedTypes = fileExtensions.filter { return knownExtensions.contains($0) }
        if detectedTypes.count > 0 {
            DDLogVerbose("Detected \(detectedTypes.count) Vagrant project type")
            return ProjectDetectionResult(id: "Vagrant", name: "Vagrant", confidencePercent: Double(detectedTypes.count) * 100.0/Double(knownExtensions.count))
        }
        return nil
    }
}
