//
//  TextColorConfigSetting.swift
//  TerminalMonitor
//
//  Created on 2025/11/16.
//

import Foundation

class TextColorConfigSetting: Codable {
    
    let id: String?
    
    let mode: TextColorMode?
    
    let color: ColorSetting?
    
    init(id: String?, mode: TextColorMode?, color: ColorSetting?) {
        self.id = id
        self.mode = mode
        self.color = color
    }
}

class TextColorConfigSettingHelper {
    
    static func save(_ value: TextColorConfig?) -> TextColorConfigSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return TextColorConfigSetting(
            id: value.id.uuidString,
            mode: value.mode,
            color: ColorSettingHelper.save(value.color)
        )
    }
    
    static func load(_ setting: TextColorConfigSetting?) -> TextColorConfig? {
        
        guard let setting = setting else {
            return nil
        }
        
        return TextColorConfig(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            mode: setting.mode ?? .fixed,
            color: ColorSettingHelper.load(setting.color)
        )
    }
}
