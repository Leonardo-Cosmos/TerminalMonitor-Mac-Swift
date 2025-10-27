//
//  FieldCondition.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

class FieldCondition: Condition {
    
    @Published var fieldKey: String {
        didSet {
            updatePublishedProperties()
        }
    }
    
    @Published var matchOperator: TextMatchOperator {
        didSet {
            updatePublishedProperties()
        }
    }
    
    @Published var targetValue: String {
        didSet {
            updatePublishedProperties()
        }
    }
    
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
        
        updatePublishedProperties()
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
    
    init(_ obj: FieldCondition) {
        self.fieldKey = obj.fieldKey
        self.matchOperator = obj.matchOperator
        self.targetValue = obj.targetValue
        
        super.init(obj)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        FieldCondition(self)
    }
    
    private func updatePublishedProperties() {
        self.conditionDescription = "\(fieldKey) \(matchOperator.description) \(targetValue) "
    }
}

func previewFieldConditions() -> [FieldCondition] {
    [
        FieldCondition(fieldKey: "timestamp", matchOperator: .equals, targetValue: "00:00"),
        FieldCondition(fieldKey: "execution", matchOperator: .equals, targetValue: "console"),
        FieldCondition(fieldKey: "plaintext", matchOperator: .equals, targetValue: "{}"),
    ]
}
