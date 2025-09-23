//
//  TextMatcher.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

class TextMatcher {
    
    static func matches(_ text: String, _ value: String, _ op: TextMatchOperator) -> Bool {
        
        switch op {
            
        case .equals:
            text == value
            
        case .contains:
            text.contains(value)
            
        case .hasPrefix:
            text.hasPrefix(value)
            
        case .hasSuffix:
            text.hasSuffix(value)
            
        case .matches:
            if let regex = try? Regex(value) {
                !text.matches(of: regex).isEmpty
            } else {
                false
            }
            
        default:
            false
        }
    }
}
