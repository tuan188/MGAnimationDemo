//
//  StringExtension.swift
//  Osake
//
//  Created by Tuan Truong on 3/7/15.
//  Copyright (c) 2015 Tuan Truong. All rights reserved.
//

import UIKit

extension String {
    static func isNilOrEmpty(string: String?) -> Bool {
        if let s = string {
            if !s.trim().isEmpty {
                return false
            }
        }
        return true
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func uriEncode() -> String {
        let allowedCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
    }
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        
        get {
            
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        
        get {
            
            return (self as NSString).stringByDeletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        
        get {
            
            return (self as NSString).stringByDeletingPathExtension
        }
    }
    var pathComponents: [String] {
        
        get {
            
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathExtension(ext)
    }
}
