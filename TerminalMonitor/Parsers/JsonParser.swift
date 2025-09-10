//
//  JsonParser.swift
//  TerminalMonitor
//
//  Created on 2025/6/30.
//

import Foundation
import os

class JsonParser {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: JsonParser.self)
    )
    
    static func isJson(text: String) -> Bool {
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmedText.hasPrefix("{") && trimmedText.hasSuffix("}")) ||
            (trimmedText.hasPrefix("[") && trimmedText.hasSuffix("]"))
    }
    
    static func parseText(text: String) -> [String: Any] {
        
        if let data = text.data(using: .utf8) {
            do {
                var result: [String: Any] = [:]
                
                let json = try JSONSerialization.jsonObject(with: data)
                
                if let jsonDict = json as? [String: Any] {
                    
                    flattenJsonPath(jsonDict: jsonDict, prefix: "", fullPathDict: &result)
                    
                } else if let jsonArray = json as? [Any] {
                    
                    flattenJsonArrayPath(jsonArry: jsonArray, prefix: "", fullPathDict: &result)
                }
                
                return result
                
            } catch {
                logger.error("Cannot parse JSON, \(text), \(error)")
                return [:]
            }
        } else {
            return [:]
        }
    }
    
    private static func flattenJsonPath(jsonDict: [String: Any], prefix: String, fullPathDict: inout [String: Any]) {
        
        for (key, value) in jsonDict {
            
            fullPathDict["\(prefix)\(key)"] = value
        }
    }
    
    private static func flattenJsonArrayPath(jsonArry: [Any], prefix: String, fullPathDict: inout [String: Any]) {
        
        for index in jsonArry.indices {
            
            fullPathDict["\(prefix)\(index)"] = jsonArry[index]
        }
    }
}
