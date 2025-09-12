//
//  WorkspaceConfig.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

import Foundation

class WorkspaceConfig: ObservableObject {
    
    @Published var commands: [CommandConfig] = []
    
    @Published var terminals: [TerminalConfig] = []
    
    func appendCommand(_ commandConfig: CommandConfig) {
        commands.append(commandConfig)
    }
    
    func insertCommand(_ commandConfig: CommandConfig, replacing id: UUID) {
        let index = commands.firstIndex { command in command.id == id }
        if let index = index {
            commands.insert(commandConfig, at: index)
        } else {
            commands.append(commandConfig)
        }
    }
    
    func insertCommand(_ commandConfig: CommandConfig, nextTo id: UUID) {
        let index = commands.firstIndex { command in command.id == id }
        if let index = index {
            commands.insert(commandConfig, at: index + 1)
        } else {
            commands.append(commandConfig)
        }
    }
    
    func deleteCommand(id: UUID) {
        commands.removeAll() { command in command.id == id}
    }
    
    func getCommand(id: UUID?) -> CommandConfig? {
        guard let id = id else {
            return nil
        }
        return commands.first(where: { $0.id == id })
    }
    
    func appendTerminal(_ terminalConfig: TerminalConfig) {
        terminals.append(terminalConfig)
    }
    
    func insertTerminal(_ terminalConfig: TerminalConfig, replacing id: UUID) {
        let index = terminals.firstIndex { command in command.id == id }
        if let index = index {
            terminals.insert(terminalConfig, at: index)
        } else {
            terminals.append(terminalConfig)
        }
    }
    
    func insertTerminal(_ terminalConfig: TerminalConfig, nextTo id: UUID) {
        let index = terminals.firstIndex { command in command.id == id }
        if let index = index {
            terminals.insert(terminalConfig, at: index + 1)
        } else {
            terminals.append(terminalConfig)
        }
    }
    
    func deleteTerminal(id: UUID) {
        terminals.removeAll() { terminal in terminal.id == id}
    }
    
    func getTerminal(id: UUID?) -> TerminalConfig? {
        guard let id = id else {
            return nil
        }
        return terminals.first(where: { $0.id == id })
    }
}

func previewWorkspaceConfig() -> WorkspaceConfig {
    let workspaceConfig = WorkspaceConfig()
    workspaceConfig.commands = previewCommandConfigs()
    workspaceConfig.terminals = previewTerminalConfigs()
    return workspaceConfig
}
