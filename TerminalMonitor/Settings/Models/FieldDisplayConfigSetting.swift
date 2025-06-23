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
    
    let headerName: String?
    
    init(id: String?, fieldKey: String, headerName: String?) {
        self.id = id
        self.fieldKey = fieldKey
        self.headerName = headerName
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
            headerName: value.headerName
        )
    }
    
    static func load(_ setting: FieldDisplayConfigSetting?) -> FieldDisplayConfig? {
        
        guard let setting = setting else {
            return nil
        }
        
        return FieldDisplayConfig(
            id: UUID(uuidString: setting.id ?? "") ?? UUID(),
            fieldKey: setting.fieldKey,
            headerName: setting.headerName
        )
    }
    
}
