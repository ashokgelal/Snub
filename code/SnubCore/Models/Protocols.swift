//
//  Protocols.swift
//  Snub
//
//  Created by Rachana Acharya on 10/17/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation

protocol ProjectTypeDetector {
    func detect(fileExtensions: [String]) -> ProjectDetectionResult?
}
