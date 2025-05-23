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
    
    var startFile: String?
    
    var arguments: String?
    
    var workDirectory: String?
    
    init(name: String, startFile: String? = nil, arguments: String? = nil, workDirectory: String? = nil) {
        self.name = name
        self.startFile = startFile
        self.arguments = arguments
        self.workDirectory = workDirectory
    }
}
