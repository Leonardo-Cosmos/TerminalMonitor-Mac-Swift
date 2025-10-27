//
//  FieldCondition.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

class FieldCondition: Condition {
    
    @Published var fieldKey: String
    
    @Published var matchOperator: TextMatchOperator
    
    @Published var targetValue: String
    
    init(id: UUID, fieldKey: String, matchOperator: TextMatchOperator, targetValue: String,
         isInverted: Bool = false,
         defaultResult: Bool = false,
         isDisabled: Bool = false) {
        self.fieldKey = fieldKey
        self.matchOperator = matchOperator
        self.targetValue = targetValue
        
        super.init(
            id: id,
            name: nil,
            isInverted: isInverted,
            defaultResult: defaultResult,
            isDisabled: isDisabled,
        )
    }
    
    convenience init(fieldKey: String, matchOperator: TextMatchOperator, targetValue: String,
                     isInverted: Bool = false,
                     defaultResult: Bool = false,
                     isDisabled: Bool = false) {
        self.init(
            id: UUID(),
            fieldKey: fieldKey,
            matchOperator: matchOperator,
            targetValue: targetValue,
            isInverted: isInverted,
            defaultResult: defaultResult,
            isDisabled: isDisabled,
        )
    }
    
    private func updatePublishedProperties() {
        self.conditionDescription = "\(fieldKey) \(matchOperator.description) \(targetValue) "
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

func previewFieldConditions() -> [FieldCondition] {
    [
        FieldCondition(fieldKey: "timestamp", matchOperator: .equals, targetValue: ""),
        FieldCondition(fieldKey: "execution", matchOperator: .equals, targetValue: ""),
        FieldCondition(fieldKey: "plaintext", matchOperator: .equals, targetValue: ""),
    ]
}
