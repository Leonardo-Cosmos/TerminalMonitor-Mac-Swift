//
//  SettingSerializer.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

import Foundation

class SettingSerializer {
    
    static func serialize(workspaceSetting: WorkspaceSetting, settingFilePath: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let json = try encoder.encode(workspaceSetting)
        try json.write(to: URL(filePath: settingFilePath, directoryHint: .notDirectory))
    }
    
    static func deserialize(settingFilePath: String) throws -> WorkspaceSetting {
        let decoder = JSONDecoder()
        let json = try Data(contentsOf: URL(filePath: settingFilePath, directoryHint: .notDirectory))
        
        return try decoder.decode(WorkspaceSetting.self, from: json)
    }
}
