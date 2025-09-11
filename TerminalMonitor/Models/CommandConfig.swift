//
//  CommandConfig.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import Foundation

class CommandConfig: Identifiable, ObservableObject, NSCopying {
    
    let id: UUID
    
    /// The name of command.
    var name: String
    
    var executableFile: String?
    
    var arguments: String?
    
    var currentDirectory: String?
    
    init(id: UUID, name: String, executableFile: String? = nil, arguments: String? = nil, currentDirectory: String? = nil) {
        self.id = id
        self.name = name
        self.executableFile = executableFile
        self.arguments = arguments
        self.currentDirectory = currentDirectory
    }
    
    convenience init(name: String, executableFile: String? = nil, arguments: String? = nil, currentDirectory: String? = nil) {
        self.init(
            id: UUID(),
            name: name,
            executableFile: executableFile,
            arguments: arguments,
            currentDirectory: currentDirectory
        )
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        CommandConfig(
            name: self.name,
            executableFile: executableFile,
            arguments: arguments,
            currentDirectory: currentDirectory,
        )
    }
}

func previewCommandConfigs() -> [CommandConfig] {
    [
        CommandConfig(name: "Console"),
        CommandConfig(name: "Application"),
        CommandConfig(name: "Tool"),
    ]
}
