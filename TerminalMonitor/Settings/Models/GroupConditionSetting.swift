//
//  GroupConditionSetting.swift
//  TerminalMonitor
//
//  Created on 2025/10/26.
//

import Foundation

class GroupConditionSetting: Codable {
    
    let id: String?
    
    let name: String?
    
    let matchMode: GroupMatchMode
    
    let conditions: [FieldConditionSetting]
     
    var isInverted: Bool
    
    var defaultResult: Bool
    
    var isDisabled: Bool
    
    init(id: String?, name: String?, matchMode: GroupMatchMode, conditions: [FieldConditionSetting],
         isInverted: Bool, defaultResult: Bool, isDisabled: Bool) {
        self.id = id
        self.name = name
        self.matchMode = matchMode
        self.conditions = conditions
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
    }
}

class GroupConditionSettingHelper {
    
    static func save(_ value: GroupCondition?) -> GroupConditionSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return GroupConditionSetting(
            id: value.id.uuidString,
            name: value.name!,
            matchMode: value.matchMode,
            conditions: value.conditions.map { FieldConditionSettingHelper.save($0 as? FieldCondition)! },
            isInverted: value.isInverted,
            defaultResult: value.defaultResult,
            isDisabled: value.isDisabled,
        )
    }
    
    static func load(_ setting: GroupConditionSetting?) -> GroupCondition? {
        
        guard let setting = setting else {
            return nil
        }
        
        return GroupCondition(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            name: setting.name,
            matchMode: setting.matchMode,
            conditions: setting.conditions.map { FieldConditionSettingHelper.load($0)! },
            isInverted: setting.isInverted,
            defaultResult: setting.defaultResult,
            isDisabled: setting.isDisabled,
        )
    }
}
