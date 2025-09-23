//
//  GroupCondition.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

class GroupCondition: Condition {
    
    var matchMode: GroupMatchMode
    
    var conditions: [Condition]
    
    init(id: UUID, name: String?, matchMode: GroupMatchMode, conditions: [Condition]) {
        self.matchMode = matchMode
        self.conditions = conditions
        
        super.init(id: id, name: name)
    }
    
    convenience init(name: String?, matchMode: GroupMatchMode, conditions: [Condition]) {
        self.init(
            id: UUID(),
            name: name,
            matchMode: matchMode,
            conditions: conditions,
        )
    }
    
    convenience init(matchMode: GroupMatchMode, conditions: [Condition]) {
        self.init(
            name: nil,
            matchMode: matchMode,
            conditions: conditions,
        )
    }
    
    init(_ obj: GroupCondition) {
        self.matchMode = obj.matchMode
        self.conditions = obj.conditions.map { condition in condition.copy() as! Condition }
        
        super.init(obj)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        GroupCondition(self)
    }
}
