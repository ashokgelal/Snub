//
//  ProjectDetector.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

public class ProjectDetector {
    public static let sharedInstance = ProjectDetector()
    private var detectors: [ProjectTypeDetector] = []
    private init() {
        addDetectors()
    }
    
    private func addDetectors() {
        detectors.append(XcodeProjectDetector())
        detectors.append(JetBrainsProjectDetector())
        detectors.append(VisualStudioCodeProjectDetector())
        detectors.append(VisualStudioProjectDetector())
        detectors.append(SublimeProjectDetector())
        detectors.append(TextMateProjectDetector())
        detectors.append(VagrantProjectDetector())
    }
    
    public func identify(url: NSURL) throws -> [ProjectDetectionResult] {
        let fm = NSFileManager.defaultManager()
        let subs = try fm.subpathsOfDirectoryAtPath(url.path!).map { $0.fileExtension() }
        let results = detectors.map { $0.detect(subs) }.filter { $0 != nil }
        return results.sort{ $0!.confidencePercent > $1!.confidencePercent }.map { $0! }
    }
}