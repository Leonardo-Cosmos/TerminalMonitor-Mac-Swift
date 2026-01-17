//
//  TerminalViewHelper.swift
//  TerminalMonitor
//
//  Created on 2025/11/30.
//

import Foundation

struct TerminalViewHelper {
    
    static func updateFieldDisplayConfigs(from newConfigs: [FieldDisplayConfig],
                                          to oldConfigs: [FieldDisplayConfig]
    ) -> [FieldDisplayConfig] {
        
        var resultConfigs: [FieldDisplayConfig] = []

        for newConfig in newConfigs {
            if let config = oldConfigs.first(where: { $0.id == newConfig.id }) {
                newConfig.to(config)
                resultConfigs.append(config)
            } else {
                let config = newConfig.copy(id: newConfig.id)
                resultConfigs.append(config)
            }
        }
        
        return resultConfigs
    }
}
