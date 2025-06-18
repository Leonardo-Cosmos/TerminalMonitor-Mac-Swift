//
//  WorkspaceConfig.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

import Foundation

class WorkspaceConfig: ObservableObject {
    
    @Published var commands: [CommandConfig] = []
    
    func append(_ commandConfig: CommandConfig) {
        commands.append(commandConfig)
    }
    
    func insert(_ commandConfig: CommandConfig, replacing id: UUID) {
        let index = commands.firstIndex { command in command.id == id }
        if let index = index {
            commands.insert(commandConfig, at: index)
        } else {
            commands.append(commandConfig)
        }
    }
    
    func delete(id: UUID) {
        commands.removeAll() { command in command.id == id}
    }
}

