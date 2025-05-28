//
//  CommandConfigSetting.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

class CommandConfigSetting: Codable {
    
    let name: String
    
    let executableFile: String?
    
    let arguments: String?
    
    let currentDirectory: String?
    
    init(name: String, executableFile: String?, arguments: String?, currentDirectory: String?) {
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
            name: setting.name,
            executableFile: setting.executableFile,
            arguments: setting.arguments,
            currentDirectory: setting.currentDirectory,
        )
    }
}
