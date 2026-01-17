//
//  TextStyleConditionSetting.swift
//  TerminalMonitor
//
//  Created on 2025/11/20.
//

import Foundation

class TextStyleConditionSetting: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case style
        case inheritDefault
        case condition
    }
    
    let id: String?
    
    let style: TextStyleConfigSetting
    
    let inheritDefault: Bool?
    
    let condition: ConditionSetting
    
    init(id: String?, style: TextStyleConfigSetting, inheritDefault: Bool?, condition: ConditionSetting) {
        self.id = id
        self.style = style
        self.inheritDefault = inheritDefault
        self.condition = condition
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.style = try container.decode(TextStyleConfigSetting.self, forKey: .style)
        self.inheritDefault = try container.decodeIfPresent(Bool.self, forKey: .inheritDefault)
        self.condition = try container.decode(ConditionSetting.self, forKey: .condition, using: ConditionSetting.decode(from:))
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
            inheritDefault: value.inheritDefault,
            condition: ConditionSettingHelper.save(value.condition)!,
        )
    }
    
    static func load(_ setting: TextStyleConditionSetting?) -> TextStyleCondition? {
        
        guard let setting = setting else {
            return nil
        }
        
        return TextStyleCondition(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            style: TextStyleConfigSettingHelper.load(setting.style)!,
            inheritDefault: setting.inheritDefault ?? false,
            condition: ConditionSettingHelper.load(setting.condition)!,
        )
    }
}
