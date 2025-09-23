//
//  FieldCondition.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

class FieldCondition: Condition {
    
    var fieldKey: String
    
    var matchOperator: TextMatchOperator
    
    var targetValue: String
    
    init(id: UUID, name: String?, fieldKey: String, matchOperator: TextMatchOperator, targetValue: String) {
        self.fieldKey = fieldKey
        self.matchOperator = matchOperator
        self.targetValue = targetValue
        
        super.init(id: id, name: name)
    }
    
    convenience init(name: String?, fieldKey: String, matchOperator: TextMatchOperator, targetValue: String) {
        self.init(
            id: UUID(),
            name: name,
            fieldKey: fieldKey,
            matchOperator: matchOperator,
            targetValue: targetValue,
        )
    }
    
    convenience init(fieldKey: String, matchOperator: TextMatchOperator, targetValue: String) {
        self.init(
            name: nil,
            fieldKey: fieldKey,
            matchOperator: matchOperator,
            targetValue: targetValue,
        )
    }
    
    init(_ obj: FieldCondition) {
        self.fieldKey = obj.fieldKey
        self.matchOperator = obj.matchOperator
        self.targetValue = obj.targetValue
        
        super.init(obj)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        FieldCondition(self)
    }
}
