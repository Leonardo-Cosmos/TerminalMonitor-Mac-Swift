//
//  CommandConfigSetting.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

import Foundation

class CommandConfigSetting: Codable {
    
    let id: String?
    
    let name: String?
    
    let executableFile: String?
    
    let arguments: String?
    
    let currentDirectory: String?
    
    init(id: String?, name: String?, executableFile: String?, arguments: String?, currentDirectory: String?) {
        self.id = id
        self.name = name
        self.executableFile = executableFile
        self.arguments = arguments
        self.currentDirectory = currentDirectory
    }
}

class CommandConfigSettingHelper {
    
    static func save(_ commandConfig: CommandConfig?) -> CommandConfigSetting? {
        
        guard let commandConfig = commandConfig else {
            return nil
        }
        
        return CommandConfigSetting(
            id: commandConfig.id.uuidString,
            name: commandConfig.name,
            executableFile: commandConfig.executableFile,
            arguments: commandConfig.arguments,
            currentDirectory: commandConfig.currentDirectory,
        )
    }
    
    static func load(_ setting: CommandConfigSetting?) -> CommandConfig? {
        
        guard let setting = setting else {
            return nil
        }
        
        return CommandConfig(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            name: setting.name ?? "?",
            executableFile: setting.executableFile,
            arguments: setting.arguments,
            currentDirectory: setting.currentDirectory,
        )
    }
}
