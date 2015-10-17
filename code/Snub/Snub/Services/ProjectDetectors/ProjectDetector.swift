//
//  ProjectDetector.swift
//  Snub
//
//  Created by Ashok Gelal on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Cocoa

class ProjectDetector {
    static let instance = ProjectDetector()
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
    
    func identify(url: NSURL) throws -> [String] {
        let fm = NSFileManager.defaultManager()
        let subs = try fm.subpathsOfDirectoryAtPath(url.path!).map { ($0 as NSString).pathExtension }
        let results = detectors.map { $0.detect(subs) }.filter { $0 != nil }
        return results.sort{ $0!.confidencePercent > $1!.confidencePercent }.map { $0!.projectType }
    }
}