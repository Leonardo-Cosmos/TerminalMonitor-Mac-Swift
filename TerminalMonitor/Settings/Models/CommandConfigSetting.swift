//
//  CommandConfigSetting.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

class CommandConfigSetting: Codable {
    
    let name: String
    
    let startFile: String?
    
    let arguments: String?
    
    let workDirectory: String?
    
    init(name: String, startFile: String?, arguments: String?, workDirectory: String?) {
        self.name = name
        self.startFile = startFile
        self.arguments = arguments
        self.workDirectory = workDirectory
    }
}

class CommandConfigSettingHelper {
    
    static func save(_ commandConfig: CommandConfig?) -> CommandConfigSetting? {
        
        guard let commandConfig = commandConfig else {
            return nil
        }
        
        return CommandConfigSetting(
            name: commandConfig.name,
            startFile: commandConfig.startFile,
            arguments: commandConfig.arguments,
            workDirectory: commandConfig.workDirectory,
        )
    }
    
    static func load(_ setting: CommandConfigSetting?) -> CommandConfig? {
        
        guard let setting = setting else {
            return nil
        }
        
        return CommandConfig(
            name: setting.name,
            startFile: setting.startFile,
            arguments: setting.arguments,
            workDirectory: setting.workDirectory,
        )
    }
}
