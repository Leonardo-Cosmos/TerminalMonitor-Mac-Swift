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
    
    var inheritDefault: Bool
    
    var condition: Condition
    
    init(id: UUID, style: TextStyleConfig, inheritDefault: Bool, condition: Condition) {
        self.id = id
        self.style = style
        self.inheritDefault = inheritDefault
        self.condition = condition
    }
    
    convenience init(style: TextStyleConfig, inheritDefault: Bool, condition: Condition) {
        self.init(
            id: UUID(),
            style: style,
            inheritDefault: inheritDefault,
            condition: condition,
        )
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        TextStyleCondition(
            style: self.style.copy() as! TextStyleConfig,
            inheritDefault: self.inheritDefault,
            condition: self.condition.copy() as! Condition,
        )
    }
}
