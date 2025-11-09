//
//  FieldConditionSetting.swift
//  TerminalMonitor
//
//  Created on 2025/10/26.
//

import Foundation

class FieldConditionSetting: Codable {
    
    let id: String?
    
    var fieldKey: String
    
    var matchOperator: TextMatchOperator
    
    var targetValue: String
    
    var isInverted: Bool
    
    var defaultResult: Bool
    
    var isDisabled: Bool
    
    init(id: String?, fieldKey: String, matchOperator: TextMatchOperator, targetValue: String,
         isInverted: Bool, defaultResult: Bool, isDisabled: Bool) {
        self.id = id
        self.fieldKey = fieldKey
        self.matchOperator = matchOperator
        self.targetValue = targetValue
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
    }
}

class FieldConditionSettingHelper {
    
    static func save(_ value: FieldCondition?) -> FieldConditionSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return FieldConditionSetting(
            id: value.id.uuidString,
            fieldKey: value.fieldKey,
            matchOperator: value.matchOperator,
            targetValue: value.targetValue,
            isInverted: value.isInverted,
            defaultResult: value.defaultResult,
            isDisabled: value.isDisabled,
        )
    }
    
    static func load(_ setting: FieldConditionSetting?) -> FieldCondition? {
        
        guard let setting = setting else {
            return nil
        }
        
        return FieldCondition(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            fieldKey: setting.fieldKey,
            matchOperator: setting.matchOperator,
            targetValue: setting.targetValue,
            isInverted: setting.isInverted,
            defaultResult: setting.defaultResult,
            isDisabled: setting.isDisabled,
        )
    }
}
