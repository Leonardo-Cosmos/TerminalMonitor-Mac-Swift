//
//  CommandConfig.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import Foundation

class CommandConfig: Identifiable {
    
    let id = UUID()
    
    /// The name of command.
    let name: String
    
    var arguments: String?
    
    init(name: String) {
        self.name = name
    }
}
