//
//  TerminalConfigSetting.swift
//  TerminalMonitor
//
//  Created on 2025/6/19.
//

import Foundation

class TerminalConfigSetting: Codable {
    
    let id: String?
    
    let name: String
    
    let visibleFields: [FieldDisplayConfigSetting]?
    
    let filterCondition: GroupConditionSetting?
    
    let findCondition: GroupConditionSetting?
    
    init(id: String?, name: String, visibleFields: [FieldDisplayConfigSetting]?,
         filterCondition: GroupConditionSetting?, findCondition: GroupConditionSetting?) {
        self.id = id
        self.name = name
        self.visibleFields = visibleFields
        self.filterCondition = filterCondition
        self.findCondition = findCondition
    }
}

class TerminalConfigSettingHelper {
    
    static func save(_ value: TerminalConfig?) -> TerminalConfigSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return TerminalConfigSetting(
            id: value.id.uuidString,
            name: value.name,
            visibleFields: value.visibleFields
                .map { FieldDisplayConfigSettingHelper.save($0)! },
            filterCondition: GroupConditionSettingHelper.save(value.filterCondition),
            findCondition: GroupConditionSettingHelper.save(value.findCondition),
        )
    }
    
    static func load(_ setting: TerminalConfigSetting?) -> TerminalConfig? {
        
        guard let setting = setting else {
            return nil
        }
        
        return TerminalConfig(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            name: setting.name,
            visibleFields: (setting.visibleFields ?? [])
                .map { FieldDisplayConfigSettingHelper.load($0)! },
            filterCondition: GroupConditionSettingHelper.load(setting.filterCondition) ?? GroupCondition.default(),
            findCondition: GroupConditionSettingHelper.load(setting.findCondition) ?? GroupCondition.default(),
        )
    }
}
