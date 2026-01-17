//
//  SettingSerializer.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

import Foundation
import os

class SettingSerializer {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SettingSerializer.self)
    )
    
    static func serialize(workspaceSetting: WorkspaceSetting, settingFilePath: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let json = try encoder.encode(workspaceSetting)
        try json.write(to: URL(filePath: settingFilePath, directoryHint: .notDirectory))
    }
    
    static func deserialize(settingFilePath: String) throws -> WorkspaceSetting {
        let decoder = JSONDecoder()
        let json = try Data(contentsOf: URL(filePath: settingFilePath, directoryHint: .notDirectory))
        
        do {
            return try decoder.decode(WorkspaceSetting.self, from: json)
        } catch let error as DecodingError {
            if let updatedJson = replaceEnumObject(json) {
                return try decoder.decode(WorkspaceSetting.self, from: updatedJson)
            } else {
                throw error
            }
        }
    }
    
    /**
     The enum type is encoded as JSON object in old version and changed to JSON string in new version.
     Replace such values to support version upgrade.
     */
    private static func replaceEnumObject(_ json: Data) -> Data? {
        Self.logger.info("Try to replace enum value of JSON object with string")
        if let jsonString = String(data: json, encoding: .utf8) {
            let replacedJsonString = jsonString.replacing(/\{\n\s+(".+") : \{\n\n\s*\}\n\s+\}/) { match in
                match.1
            }
            
            return replacedJsonString.data(using: .utf8)
        }
        
        return nil
    }
}
