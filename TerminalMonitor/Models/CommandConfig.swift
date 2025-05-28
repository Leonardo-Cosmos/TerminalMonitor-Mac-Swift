//
//  CommandConfig.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import Foundation

class CommandConfig: Identifiable, ObservableObject {
    
    let id = UUID()
    
    /// The name of command.
    var name: String
    
    var executableFile: String?
    
    var arguments: String?
    
    var currentDirectory: String?
    
    init(name: String, executableFile: String? = nil, arguments: String? = nil, currentDirectory: String? = nil) {
        self.name = name
        self.executableFile = executableFile
        self.arguments = arguments
        self.currentDirectory = currentDirectory
    }
}
