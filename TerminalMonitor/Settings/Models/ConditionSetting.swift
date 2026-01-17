//
//  ConditionSetting.swift
//  TerminalMonitor
//
//  Created on 2026/1/2.
//

import Foundation

class ConditionSetting: Codable {
    
    let id: String?
    
    let name: String?
    
    let isInverted: Bool
    
    let defaultResult: Bool
    
    let isDisabled: Bool
    
    init(id: String?, name: String?, isInverted: Bool, defaultResult: Bool, isDisabled: Bool) {
        self.id = id
        self.name = name
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
    }
    
    static func decode(from decoder: any Decoder) throws -> ConditionSetting {
        let container = try decoder.container(keyedBy: GroupConditionSetting.CodingKeys.self)
        let matchMode = try? container.decode(GroupMatchMode.self, forKey: .matchMode)
        
        if matchMode != nil {
            return try GroupConditionSetting(from: decoder)
        } else {
            return try FieldConditionSetting(from: decoder)
        }
    }
}

class ConditionSettingHelper {
    
    static func save(_ value: Condition?) -> ConditionSetting? {
        
        guard let value = value else {
            return nil
        }
        
        var setting: ConditionSetting?
        if let fieldCondition = value as? FieldCondition {
            setting = FieldConditionSettingHelper.save(fieldCondition)
            
        } else if let groupCondition = value as? GroupCondition {
            setting = GroupConditionSettingHelper.save(groupCondition)
            
        } else {
            fatalError("Unknown condition type: \(type(of: value))")
        }
        
        return setting
    }
    
    static func load(_ setting: ConditionSetting?) -> Condition? {
        
        guard let setting = setting else {
            return nil
        }
        
        var condition: Condition?
        if let fieldConditionSetting = setting as? FieldConditionSetting {
            condition = FieldConditionSettingHelper.load(fieldConditionSetting)
            
        } else if let groupConditionSetting = setting as? GroupConditionSetting {
            condition = GroupConditionSettingHelper.load(groupConditionSetting)
            
        } else {
            fatalError("Unknown condition type: \(type(of: setting))")
        }
        
        return condition
    }
}
