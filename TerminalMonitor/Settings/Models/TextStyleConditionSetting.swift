//
//  TextStyleConditionSetting.swift
//  TerminalMonitor
//
//  Created on 2025/11/20.
//

import Foundation

class TextStyleConditionSetting: Codable {
    
    let id: String?
    
    let style: TextStyleConfigSetting
    
    let condition: FieldConditionSetting
    
    init(id: String?, style: TextStyleConfigSetting, condition: FieldConditionSetting) {
        self.id = id
        self.style = style
        self.condition = condition
    }
}

class TextStyleConditionSettingHelper {
    
    static func save(_ value: TextStyleCondition?) -> TextStyleConditionSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return TextStyleConditionSetting(
            id: value.id.uuidString,
            style: TextStyleConfigSettingHelper.save(value.style)!,
            condition: FieldConditionSettingHelper.save(value.condition)!,
        )
    }
    
    static func load(_ setting: TextStyleConditionSetting?) -> TextStyleCondition? {
        
        guard let setting = setting else {
            return nil
        }
        
        return TextStyleCondition(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            style: TextStyleConfigSettingHelper.load(setting.style)!,
            condition: FieldConditionSettingHelper.load(setting.condition)!,
        )
    }
}
