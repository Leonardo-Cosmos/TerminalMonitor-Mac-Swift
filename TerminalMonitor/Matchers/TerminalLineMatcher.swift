//
//  TerminalLineMatcher.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

class TerminalLineMatcher {
    
    let matchCondition: Condition
    
    init(matchCondition: Condition) {
        self.matchCondition = matchCondition
    }
    
    func matches(terminalLine: TerminalLine) -> Bool {
        Self.matches(terminalLine: terminalLine, matchCondition: matchCondition)
    }
    
    static func matches(terminalLine: TerminalLine, matchCondition: Condition) -> Bool {
        
        if let groupCondition = matchCondition as? GroupCondition {
            matches(terminalLine: terminalLine, groupCondition: groupCondition)
            
        } else if let fieldCondition = matchCondition as? FieldCondition {
            matches(terminalLine: terminalLine, fieldCondition: fieldCondition)
            
        } else {
            false
        }
    }
    
    static func matches(terminalLine: TerminalLine, groupCondition: GroupCondition) -> Bool {
        
        let conditions = groupCondition.conditions.filter { condition in !condition.isDisabled }
        
        var groupMatched = false
        if groupCondition.isDisabled {
            groupMatched = false
            
        } else if conditions.isEmpty {
            groupMatched = groupCondition.defaultResult
            
        } else {
            groupMatched = switch groupCondition.matchMode {
            case .all:
                conditions.allSatisfy { condition in matches(terminalLine: terminalLine, matchCondition: condition) }
            case .any:
                conditions.contains { condition in matches(terminalLine: terminalLine, matchCondition: condition) }
            }
        }
        
        // The result is logical exclusive OR
        return groupMatched != groupCondition.isInverted
    }
    
    static func matches(terminalLine: TerminalLine, fieldCondition: FieldCondition) -> Bool {
        
        var fieldMatched: Bool
        if fieldCondition.isDisabled {
            fieldMatched = false
            
        } else {
            if let lineField = terminalLine.lineFieldDict[fieldCondition.fieldKey] {
                fieldMatched = TextMatcher.matches(lineField.text, fieldCondition.targetValue, fieldCondition.matchOperator)
                
            } else {
                fieldMatched = fieldCondition.defaultResult
            }
        }
        
        // The result is logical exclusive OR
        return fieldMatched != fieldCondition.isInverted
    }
}
