//
//  TextStyleConfigSetting.swift
//  TerminalMonitor
//
//  Created on 2025/11/16.
//

import Foundation

class TextStyleConfigSetting: Codable {
    
    let id: String?
    
    let foreground: TextColorConfigSetting?
    
    let background: TextColorConfigSetting?
    
    let lineLimit: Int?
    
    init(id: String?, foreground: TextColorConfigSetting?, background: TextColorConfigSetting?, lineLimit: Int?) {
        self.id = id
        self.foreground = foreground
        self.background = background
        self.lineLimit = lineLimit
    }
}

class TextStyleConfigSettingHelper {
    
    static func save(_ value: TextStyleConfig?) -> TextStyleConfigSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return TextStyleConfigSetting(
            id: value.id.uuidString,
            foreground: TextColorConfigSettingHelper.save(value.foreground),
            background: TextColorConfigSettingHelper.save(value.background),
            lineLimit: value.lineLimit,
        )
    }
    
    static func load(_ setting: TextStyleConfigSetting?) -> TextStyleConfig? {
        
        guard let setting = setting else {
            return nil
        }
        
        return TextStyleConfig(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            foreground: TextColorConfigSettingHelper.load(setting.foreground),
            background: TextColorConfigSettingHelper.load(setting.background),
            lineLimit: setting.lineLimit,
        )
    }
}
