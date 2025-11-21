//
//  FieldDisplayConfigSetting.swift
//  TerminalMonitor
//
//  Created on 2025/6/19.
//

import Foundation

class FieldDisplayConfigSetting: Codable {
    
    let id: String?
    
    let fieldKey: String
    
    let hidden: Bool
    
    let headerName: String?
    
    let customzieStyle: Bool
    
    let style: TextStyleConfigSetting?
    
    let conditions: [TextStyleConditionSetting]?
    
    init(id: String?, fieldKey: String, hidden: Bool, headerName: String?, customzieStyle: Bool, style: TextStyleConfigSetting?, conditions: [TextStyleConditionSetting]?) {
        self.id = id
        self.fieldKey = fieldKey
        self.hidden = hidden
        self.headerName = headerName
        self.customzieStyle = customzieStyle
        self.style = style
        self.conditions = conditions
    }
}

class FieldDisplayConfigSettingHelper {
    
    static func save(_ value: FieldDisplayConfig?) -> FieldDisplayConfigSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return FieldDisplayConfigSetting(
            id: value.id.uuidString,
            fieldKey: value.fieldKey,
            hidden: value.hidden,
            headerName: value.headerName,
            customzieStyle: value.customizeStyle,
            style: TextStyleConfigSettingHelper.save(value.style),
            conditions: value.conditions.map { TextStyleConditionSettingHelper.save($0)! },
        )
    }
    
    static func load(_ setting: FieldDisplayConfigSetting?) -> FieldDisplayConfig? {
        
        guard let setting = setting else {
            return nil
        }
        
        return FieldDisplayConfig(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            fieldKey: setting.fieldKey,
            hidden: setting.hidden,
            headerName: setting.headerName,
            customizeStyle: setting.customzieStyle,
            style: TextStyleConfigSettingHelper.load(setting.style) ?? TextStyleConfig.default(),
            conditions: setting.conditions?.map { TextStyleConditionSettingHelper.load($0)! } ?? []
        )
    }
}
