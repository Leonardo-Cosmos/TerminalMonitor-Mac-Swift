//
//  WorkspaceSetting.swift
//  TerminalMonitor
//
//  Created on 2025/5/21.
//

import Foundation

class WorkspaceSetting: Codable {
    
    let commands: [CommandConfigSetting]?
    
    let terminals: [TerminalConfigSetting]?
    
    init(commands: [CommandConfigSetting]? = nil, terminals: [TerminalConfigSetting]? = nil) {
        self.commands = commands
        self.terminals = terminals
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.commands, forKey: .commands)
        try container.encodeIfPresent(self.terminals, forKey: .terminals)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.commands = try container.decodeIfPresent([CommandConfigSetting].self, forKey: .commands)
        self.terminals = try container.decodeIfPresent([TerminalConfigSetting].self, forKey: .terminals)
    }
    
    enum CodingKeys: CodingKey {
        case commands
        case terminals
    }
}
