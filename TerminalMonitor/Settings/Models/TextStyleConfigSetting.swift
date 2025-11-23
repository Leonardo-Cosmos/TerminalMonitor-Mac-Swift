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
    
    let cellBackground: TextColorConfigSetting?
    
    let alignment: FrameAlignment?
    
    let lineLimit: Int?
    
    let truncationMode: TextTruncationMode?
    
    init(id: String?, foreground: TextColorConfigSetting?, background: TextColorConfigSetting?, cellBackground: TextColorConfigSetting?, alignment: FrameAlignment?, lineLimit: Int?, truncationMode: TextTruncationMode?) {
        self.id = id
        self.foreground = foreground
        self.background = background
        self.cellBackground = cellBackground
        self.alignment = alignment
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
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
            cellBackground: TextColorConfigSettingHelper.save(value.cellBackground),
            alignment: value.alignment,
            lineLimit: value.lineLimit,
            truncationMode: value.truncationMode,
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
            cellBackground: TextColorConfigSettingHelper.load(setting.cellBackground),
            alignment: setting.alignment,
            lineLimit: setting.lineLimit,
            truncationMode: setting.truncationMode,
        )
    }
}
