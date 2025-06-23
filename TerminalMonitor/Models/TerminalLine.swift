//
//  TerminalLine.swift
//  TerminalMonitor
//
//  Created on 2025/5/28.
//

import Foundation

class TerminalLine: Identifiable {
    
    let id: UUID
    
    let timestamp: Date
    
    let plaintext: String
    
    /**
     A dictionary of line fields with full path as the key.
     */
    let lineFieldDict: [String: TerminalLineField]
    
    init(id: UUID, timestamp: Date, plaintext: String, lineFieldDict: [String : TerminalLineField]) {
        self.id = id
        self.timestamp = timestamp
        self.plaintext = plaintext
        self.lineFieldDict = lineFieldDict
    }
}
