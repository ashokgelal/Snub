//
//  LicenseService.swift
//  SnubCore
//
//  Created by Ashok Gelal on 10/24/15.
//  Copyright © 2015 RnA Apps. All rights reserved.
//

import Foundation
import CocoaLumberjack

public class LicenseService {
    public static let sharedInstance = LicenseService()
    private let licenseValuesSeparator = "#"
    private let licenseFilename = ".snubmeta"
    private let productPermalink = "lightpaper"
    private let licenseReverificationDays = 30
    
    private init() {}

    public func checkLocalLicenseKey() throws -> LicenseInfo? {
        let licenseInfo = try readLicenseKey()
        guard let date = licenseInfo.lastCheckedDate else {
            // error; requires verifying with the remote server
            return nil
        }
        if NSDate().daysFrom(date) <= licenseReverificationDays {
            // success; can continue using the same license
            return licenseInfo
        }
        // too long since license verfied; requires reverification
        return LicenseInfo(key: licenseInfo.key, email: "")
    }
   
    public func verifyLicenseKey(key: String, onCompletion: (licenseInfo: LicenseInfo?, error: NSError?)->()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.gumroad.com/v2/licenses/verify")!)
        request.HTTPMethod = "POST"
        let postString = "product_permalink=\(productPermalink)&license_key=\(key)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            [unowned self]
            data, response, error in
            
            do {
                guard error == nil else {
                    DDLogError(error!.localizedDescription)
                    throw error!
                }
               
                if(NSFileManager.defaultManager().checkIfFileExists(self.getLicenseFilePath())) {
                    try NSFileManager.defaultManager().removeItemAtPath(self.getLicenseFilePath())
                }
                
                guard let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 else {
                    throw NSError(domain: "License", code: 404, userInfo: nil)
                }
                
                let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                let refunded = (jsonResult["purchase"]?["refunded"]! as! Bool)
                let chargebacked = (jsonResult["purchase"]?["chargebacked"]! as! Bool)
                if refunded || chargebacked {
                    throw NSError(domain: "License", code: 402, userInfo: nil)
                }
                let email = (jsonResult["purchase"]?["email"]! as! String)
                try self.updateLicenseKey(key, forEmail: email)
                onCompletion(licenseInfo: LicenseInfo(key: key, email: email), error: nil)
            } catch let err as NSError {
                onCompletion(licenseInfo: nil, error: err)
            }
        }
        task.resume()
    }
    
    private func updateLicenseKey(key: String, forEmail email: String) throws {
        // format: key#email#date
        let now = NSDate()
        let dateString = getDateFormatter().stringFromDate(now)
        let output = "\(key)\(licenseValuesSeparator)\(email)\(licenseValuesSeparator)\(dateString)"
        try output.writeToFile(getLicenseFilePath(), atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    private func getDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    private func readLicenseKey() throws -> LicenseInfo {
        let licenseFilePath = getLicenseFilePath()
        guard NSFileManager.defaultManager().checkIfFileExists(licenseFilePath) else {
            DDLogWarn("\(self.licenseFilename) file doesn't exist")
            throw LicenseError.LicenseFileNotFound
        }
        do {
            let contents = try String(contentsOfFile: licenseFilePath)
            let vals = contents.characters.split { $0 == "#" }.map(String.init)
            guard vals.count == 3 else {
                DDLogWarn("Error reading the contents of \(self.licenseFilename)")
                throw LicenseError.LicenseCorrupted
            }
            guard let date = getDateFormatter().dateFromString(vals[2]) else {
                DDLogWarn("Invalid date string \(vals[2])")
                throw LicenseError.LicenseCorrupted
            }
            DDLogInfo("Successfully verified Remote License")
            return LicenseInfo(key: vals[0], email: vals[1], checkedDate: date)
        } catch let error as LicenseError {
            throw error
        } catch {
            DDLogWarn("Error reading the contents of \(self.licenseFilename)")
            throw LicenseError.LicenseFileNotFound
        }
    }
    
    private func getLicenseFilePath() -> String {
        let fm = NSFileManager.defaultManager()
        let appDirectoryPath = fm.getApplicationDirectoryPath()
        return appDirectoryPath.appendPathComponent(licenseFilename)
    }
}