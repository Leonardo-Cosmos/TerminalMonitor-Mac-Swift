//
//  FieldConditionSetting.swift
//  TerminalMonitor
//
//  Created on 2025/10/26.
//

import Foundation

class FieldConditionSetting: ConditionSetting {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isInverted
        case defaultResult
        case isDisabled
        case fieldKey
        case matchOperator
        case targetValue
    }
    
    let fieldKey: String
    
    let matchOperator: TextMatchOperator
    
    let targetValue: String
    
    init(id: String?, fieldKey: String, matchOperator: TextMatchOperator, targetValue: String,
         isInverted: Bool, defaultResult: Bool, isDisabled: Bool) {
        self.fieldKey = fieldKey
        self.matchOperator = matchOperator
        self.targetValue = targetValue
        
        super.init(
            id: id,
            name: nil,
            isInverted: isInverted,
            defaultResult: defaultResult,
            isDisabled: isDisabled,
        )
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fieldKey = try container.decode(String.self, forKey: .fieldKey)
        self.matchOperator = try container.decode(TextMatchOperator.self, forKey: .matchOperator)
        self.targetValue = try container.decode(String.self, forKey: .targetValue)
        
        super.init(
            id: try container.decodeIfPresent(String.self, forKey: .id),
            name: try container.decodeIfPresent(String.self, forKey: .name),
            isInverted: false,
            defaultResult: false,
            isDisabled: false,
        )
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fieldKey, forKey: .fieldKey)
        try container.encode(matchOperator, forKey: .matchOperator)
        try container.encode(targetValue, forKey: .targetValue)
        
        try super.encode(to: encoder)
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
