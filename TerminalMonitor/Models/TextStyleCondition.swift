//
//  TextStyleCondition.swift
//  TerminalMonitor
//
//  Created on 2025/11/16.
//

import Foundation

class TextStyleCondition: Identifiable, NSCopying {
    
    let id: UUID
    
    var style: TextStyleConfig
    
    var condition: Condition
    
    init(id: UUID, style: TextStyleConfig, condition: Condition) {
        self.id = id
        self.style = style
        self.condition = condition
    }
    
    convenience init(style: TextStyleConfig, condition: Condition) {
        self.init(
            id: UUID(),
            style: style,
            condition: condition
        )
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        TextStyleCondition(
            style: self.style.copy() as! TextStyleConfig,
            condition: self.condition.copy() as! Condition
        )
    }
}
