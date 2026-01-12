//
//  GroupConditionSetting.swift
//  TerminalMonitor
//
//  Created on 2025/10/26.
//

import Foundation

class GroupConditionSetting: ConditionSetting {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isInverted
        case defaultResult
        case isDisabled
        case matchMode
        case conditions
    }
    
    let matchMode: GroupMatchMode
    
    let conditions: [ConditionSetting]
    
    init(id: String?, name: String?, matchMode: GroupMatchMode, conditions: [ConditionSetting],
         isInverted: Bool, defaultResult: Bool, isDisabled: Bool) {
        self.matchMode = matchMode
        self.conditions = conditions
        
        super.init(
            id: id,
            name: name,
            isInverted: isInverted,
            defaultResult: defaultResult,
            isDisabled: isDisabled,
        )
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.matchMode = try container.decode(GroupMatchMode.self, forKey: .matchMode)
        self.conditions = try container.decode([ConditionSetting].self, forKey: .conditions, using: ConditionSetting.decode(from:))
        
        super.init(
            id: try container.decodeIfPresent(String.self, forKey: .id),
            name: try container.decodeIfPresent(String.self, forKey: .name),
            isInverted: try container.decode(Bool.self, forKey: .isInverted),
            defaultResult: try container.decode(Bool.self, forKey: .defaultResult),
            isDisabled: try container.decode(Bool.self, forKey: .isDisabled),
        )
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matchMode, forKey: .matchMode)
        try container.encode(conditions, forKey: .conditions)
        
        try super.encode(to: encoder)
    }
}

class GroupConditionSettingHelper {
    
    static func save(_ value: GroupCondition?) -> GroupConditionSetting? {
        
        guard let value = value else {
            return nil
        }
        
        return GroupConditionSetting(
            id: value.id.uuidString,
            name: value.name,
            matchMode: value.matchMode,
            conditions: value.conditions.map { ConditionSettingHelper.save($0)! },
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
            conditions: setting.conditions.map { ConditionSettingHelper.load($0)! },
            isInverted: setting.isInverted,
            defaultResult: setting.defaultResult,
            isDisabled: setting.isDisabled,
        )
    }
}
