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
    
    @State var title: String
    
    @ObservedObject var groupCondition: GroupCondition
    
    @State private var isExpanded = true
    
    @State private var selectedItems: Set<UUID> = []
    
    @State private var selectedItem: UUID?
    
    @State private var selectMultiItems = false
    
    var onApplied: () -> Void
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: {
            HFlow {
                ForEach(groupCondition.conditions) { condition in
                    Button(action: { onConditionClicked(conditionId: condition.id)}) {
                        HStack {
                            Text(condition.conditionDescription)
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                if condition.isInverted {
                                    SymbolButton(systemImage: "minus.circle.fill", symbolColor: .red) {
                                        condition.isInverted = false
                                    }
                                    .help("Matching is Inverted")
                                } else {
                                    SymbolButton(systemImage: "largecircle.fill.circle", symbolColor: .green) {
                                        condition.isInverted = true
                                    }
                                    .help("Matching is not Inverted")
                                }
                                
                                if condition.defaultResult {
                                    SymbolButton(systemImage: "star.fill", symbolColor: .yellow) {
                                        condition.defaultResult = false
                                    }
                                    .help("Default to True when the Field is not Found")
                                } else {
                                    SymbolButton(systemImage: "star", symbolColor: .yellow) {
                                        condition.defaultResult = true
                                    }
                                    .help("Default to False when the Field is not Found")
                                }
                                
                                if condition.isDisabled {
                                    SymbolButton(systemImage: "pause.circle", symbolColor: .red) {
                                        condition.isDisabled = false
                                    }
                                    .help("This Condition is Disabled")
                                } else {
                                    SymbolButton(systemImage: "dot.circle", symbolColor: .green) {
                                        condition.isDisabled = true
                                    }
                                    .help("This Condition is Enabled")
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .foregroundStyle(buttonForeground(condition.id))
                        .background(buttonBackground(condition.id))
                        .backgroundStyle(buttonBackground(condition.id))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(nsColor: NSColor.lightGray), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            ConditionListHelper.openConditionDetailWindow(condition: condition)
                        }
                    }
                }
            }
        }, label: {
            HStack {
                Text(title)
                
                Button("Add", systemImage: "plus") {
                    addCondition()
                }
                .labelStyle(.iconOnly)
                
                Button("Remove", systemImage: "minus") {
                    removeSelectedCondition()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Button("Edit", systemImage: "pencil") {
                    editSelectedCondition()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Button("Move Left", systemImage: "arrowshape.left.fill") {
                    moveSelectedConditionsLeft()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Button("Move Right", systemImage: "arrowshape.right.fill") {
                    moveSelectedConditionsRight()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Spacer()
                
                if groupCondition.matchMode == .all {
                    Button("∀") {
                        groupCondition.matchMode = .any
                    }
                    .help("Match all conditions")
                } else {
                    Button("∃") {
                        groupCondition.matchMode = .all
                    }
                    .help("Match any conditions")
                }
                
                if groupCondition.isInverted {
                    SymbolButton(systemImage: "minus.circle.fill", symbolColor: .red) {
                        groupCondition.isInverted = false
                    }
                    .help("Matching is Inverted")
                } else {
                    SymbolButton(systemImage: "largecircle.fill.circle", symbolColor: .green) {
                        groupCondition.isInverted = true
                    }
                    .help("Matching is not Inverted")
                }
                
                if groupCondition.defaultResult {
                    SymbolButton(systemImage: "star.fill", symbolColor: .yellow) {
                        groupCondition.defaultResult = false
                    }
                    .help("Default to True when the Field is not Found")
                } else {
                    SymbolButton(systemImage: "star", symbolColor: .yellow) {
                        groupCondition.defaultResult = true
                    }
                    .help("Default to False when the Field is not Found")
                }
                
                if groupCondition.isDisabled {
                    SymbolButton(systemImage: "pause.circle", symbolColor: .red) {
                        groupCondition.isDisabled = false
                    }
                    .help("This Condition is Disabled")
                } else {
                    SymbolButton(systemImage: "dot.circle", symbolColor: .green) {
                        groupCondition.isDisabled = true
                    }
                    .help("This Condition is Enabled")
                }
                
                Spacer()
                
                Button("Select", systemImage: selectMultiItems ? "checklist.checked" : "checklist") {
                    if selectMultiItems {
                        selectedItems.removeAll()
                        if let selectedField = selectedItem {
                            selectedItems.insert(selectedField)
                        }
                    }
                    selectMultiItems.toggle()
                }
                .labelStyle(.iconOnly)
                .help(selectMultiItems ? "Multiple Selection" : "Single Selection")
                
                Button("Apply", systemImage: "checkmark") {
                    onApplied()
                }
                .labelStyle(.iconOnly)
                .help("Apply Condition Changes")
            }
        })
    }
    
    private func onConditionClicked(conditionId: UUID) {
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
            if let selectedCondition = groupCondition.conditions.first(where: { $0.id == conditionId }) {
                selectedConditions.append(selectedCondition)
            }
        }
        
        if byOrder {
            selectedConditions.sort(by: { conditionX, conditionY in
                let indexX = groupCondition.conditions.firstIndex(where: { $0.id == conditionX.id }) ?? 0
                let indexY = groupCondition.conditions.firstIndex(where: { $0.id == conditionY.id }) ?? 0
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
            ConditionListHelper.addCondition(condition: condition, conditions: &groupCondition.conditions, replacing: nil)
        }
    }
    
    private func removeSelectedCondition() {
        forEachSelectedCondition { selectedCondition in
            ConditionListHelper.removeCondition(conditionId: selectedCondition.id, conditions: &groupCondition.conditions)
        }
    }
    
    private func editSelectedCondition() {
        forEachSelectedCondition { selectedCondition in
            ConditionListHelper.openConditionDetailWindow(condition: selectedCondition) { condition in
                if let index = groupCondition.conditions.firstIndex(where: { $0.id == selectedCondition.id }) {
                    groupCondition.conditions[index] = condition
                }
            }
        }
    }
    
    private func moveSelectedConditionsLeft() {
        forEachSelectedCondition(byOrder: true, reverseOrder: false) { selectedCondition in
            ConditionListHelper.moveConditionLeft(conditionId: selectedCondition.id, conditions: &groupCondition.conditions)
        }
    }
    
    private func moveSelectedConditionsRight() {
        forEachSelectedCondition(byOrder: true, reverseOrder: true) { selectedCondition in
            ConditionListHelper.moveConditionRight(conditionId: selectedCondition.id, conditions: &groupCondition.conditions)
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
    ConditionListView(title: "Conditions", groupCondition: previewGroupCondition(), onApplied: {})
}
