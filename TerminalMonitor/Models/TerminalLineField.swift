//
//  TerminalLineField.swift
//  TerminalMonitor
//
//  Created on 2025/5/28.
//

import Foundation

class TerminalLineField {
    
    /**
     Original key in parsed result.
     */
    let key: String
    
    /**
     The full path that starts with category prefix. It is unique in a terminal line.
     */
    let fieldKey: String
    
    /**
     Original value in parsed result.
     */
    let value: Any?
    
    /**
     String representation of the value.
     */
    let text: String
    
    init(key: String, fieldKey: String, value: Any?, text: String) {
        self.key = key
        self.fieldKey = fieldKey
        self.value = value
        self.text = text
    }
}
