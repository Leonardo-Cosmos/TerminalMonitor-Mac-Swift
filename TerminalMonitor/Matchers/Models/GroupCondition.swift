//
//  GroupCondition.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

class GroupCondition: Condition {
    
    @Published var matchMode: GroupMatchMode
    
    @Published var conditions: [Condition]
    
    init(id: UUID, name: String?, matchMode: GroupMatchMode, conditions: [Condition],
         isInverted: Bool = false,
         defaultResult: Bool = false,
         isDisabled: Bool = false) {
        self.matchMode = matchMode
        self.conditions = conditions
        
        super.init(
            id: id,
            name: name,
            isInverted: isInverted,
            defaultResult: defaultResult,
            isDisabled: isDisabled,
        )
    }
    
    convenience init(name: String?, matchMode: GroupMatchMode, conditions: [Condition],
                     isInverted: Bool = false,
                     defaultResult: Bool = false,
                     isDisabled: Bool = false) {
        self.init(
            id: UUID(),
            name: name,
            matchMode: matchMode,
            conditions: conditions,
            isInverted: isInverted,
            defaultResult: defaultResult,
            isDisabled: isDisabled,
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
    
    static func `default`() -> GroupCondition {
        GroupCondition(name: "", matchMode: .all, conditions: [])
    }
}

func previewGroupCondition() -> GroupCondition {
    GroupCondition(
        name: "preview group",
        matchMode: .all,
        conditions: previewFieldConditions(),
    )
}
