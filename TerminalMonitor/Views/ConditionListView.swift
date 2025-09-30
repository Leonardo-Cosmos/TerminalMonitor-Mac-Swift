//
//  ConditionListView.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import SwiftUI
import Flow

struct ConditionListView: View {
    
    private static let selectedButtonForeground = Color(nsColor: NSColor.selectedControlTextColor)
    
    private static let unselectedButtonForeground = Color(nsColor: NSColor.controlTextColor)
    
    private static let selectedButtonBackground = Color(nsColor: NSColor.selectedControlColor)
    
    private static let unselectedButtonBackground = Color(nsColor: NSColor.controlColor)
    
    @State var conditions: [Condition] = []
    
    @State private var isExpanded = true
    
    @State private var selectedItems: Set<UUID> = []
    
    @State private var selectedItem: UUID?
    
    @State private var selectMultiItems = false
    
    var onApplied: ([Condition]) -> Void
    
    var body: some View {
        
    }
    
    private func onconditionClicked(conditionId: UUID) {
        if selectMultiItems {
            if selectedItems.contains(conditionId) {
                selectedItems.remove(conditionId)
                if selectedItem == conditionId {
                    selectedItem = nil
                }
            } else {
                selectedItems.insert(conditionId)
                selectedItem = conditionId
            }
        } else {
            if selectedItem == conditionId {
                selectedItem = nil
                selectedItems.removeAll()
            } else {
                selectedItem = conditionId
                selectedItems.removeAll()
                selectedItems.insert(conditionId)
            }
        }
    }
    
    private func buttonForeground(_ conditionId: UUID) -> Color {
        if selectedItems.contains(conditionId) {
            return Self.selectedButtonForeground
        } else {
            return Self.unselectedButtonForeground
        }
    }
    
    private func buttonBackground(_ conditionId: UUID) -> Color {
        if selectedItems.contains(conditionId) {
            return Self.selectedButtonBackground
        } else {
            return Self.unselectedButtonBackground
        }
    }
    
    private func forEachSelectedCondition(byOrder: Bool = false, reverseOrder: Bool = false,
                                      action: (Condition) -> Void) {
        var selectedConditions: [Condition] = []
        for conditionId in selectedItems {
            if let selectedCondition = conditions.first(where: { $0.id == conditionId }) {
                selectedConditions.append(selectedCondition)
            }
        }
        
        if byOrder {
            selectedConditions.sort(by: { conditionX, conditionY in
                let indexX = conditions.firstIndex(where: { $0.id == conditionX.id }) ?? 0
                let indexY = conditions.firstIndex(where: { $0.id == conditionY.id }) ?? 0
                return indexX < indexY
            })
        }
        
        if reverseOrder {
            selectedConditions.reverse()
        }
        
        for selectedCondition in selectedConditions {
            action(selectedCondition)
        }
    }
    
    private func addCondition() {
        ConditionListHelper.openConditionDetailWindow { condition in
            ConditionListHelper.addCondition(condition: condition, conditions: &conditions, replacing: nil)
        }
    }
    
    private func removeSelectedcondition() {
        forEachSelectedCondition { selectedCondition in
            ConditionListHelper.removeCondition(conditionId: selectedCondition.id, conditions: &conditions)
        }
    }
    
    private func editSelectedcondition() {
        forEachSelectedCondition { selectedCondition in
            ConditionListHelper.openConditionDetailWindow(condition: selectedCondition)
        }
    }
    
    private func moveSelectedConditionsLeft() {
        forEachSelectedCondition(byOrder: true, reverseOrder: false) { selectedCondition in
            ConditionListHelper.moveConditionLeft(conditionId: selectedCondition.id, conditions: &conditions)
        }
    }
    
    private func moveSelectedconditionsRight() {
        forEachSelectedCondition(byOrder: true, reverseOrder: true) { selectedCondition in
            ConditionListHelper.moveConditionRight(conditionId: selectedCondition.id, conditions: &conditions)
        }
    }
}

struct ConditionListHelper {
    
    static func openConditionDetailWindow(condition: Condition? = nil, onSave: ((Condition) -> Void)? = nil) {
        
        var condition = condition ?? FieldCondition(fieldKey: "", matchOperator: .contains, targetValue: "")
        
        ConditionDetailWindowController.openWindow(for: Binding(
            get: { condition },
            set: { condition = $0 }
        ), onSave: onSave)
    }
    
    static func addCondition(condition: Condition, conditions: inout [Condition], replacing conditionId: UUID?) {
        
        if let conditionId = conditionId, let index = conditions.firstIndex(where: { $0.id == conditionId }) {
            conditions.insert(condition, at: index)
        } else {
            conditions.append(condition)
        }
    }
    
    static func removeCondition(conditionId: UUID, conditions: inout [Condition]) {
        
        conditions.removeAll() { condition in condition.id == conditionId }
    }
    
    static func moveConditionLeft(conditionId: UUID, conditions: inout [Condition]) {
        guard let srcIndex = conditions.firstIndex(where: { $0.id == conditionId }) else {
            return
        }
        
        let dstIndex = (srcIndex - 1 + conditions.count) % conditions.count
        
        let condition = conditions[srcIndex]
        conditions.remove(at: srcIndex)
        conditions.insert(condition, at: dstIndex)
    }
    
    static func moveConditionRight(conditionId: UUID, conditions: inout [Condition]) {
        guard let srcIndex = conditions.firstIndex(where: { $0.id == conditionId }) else {
            return
        }
        
        let dstIndex = (srcIndex + 1) % conditions.count
        
        let condition = conditions[srcIndex]
        conditions.remove(at: srcIndex)
        conditions.insert(condition, at: dstIndex)
    }
}


#Preview {
    ConditionListView(conditions: previewConditions(), onApplied: { conditions in })
}
