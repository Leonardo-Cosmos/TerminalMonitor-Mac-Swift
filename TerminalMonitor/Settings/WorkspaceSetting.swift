//
//  WorkspaceSetting.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

import Foundation

class WorkspaceSetting: Codable {
    
    let commands: [CommandConfigSetting]?
    
    init(commands: [CommandConfigSetting]? = nil) {
        self.commands = commands
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.commands, forKey: .commands)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.commands = try container.decodeIfPresent([CommandConfigSetting].self, forKey: .commands)
    }
    
    enum CodingKeys: CodingKey {
        case commands
    }
}
