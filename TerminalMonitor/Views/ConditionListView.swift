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
                    ConditionListItemView(
                        condition: condition,
                        onConditionClicked: { onConditionClicked(conditionId: $0) },
                        buttonForeground: buttonForeground,
                        buttonBackground: buttonBackground,
                    )
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            editCondtion(condition)
                        }
                        
                        Button("Remove", systemImage: "minus") {
                            removeCondtion(condition)
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
                
                TextButtonToggle(
                    toggle: Binding(
                        get: { groupCondition.matchMode == .all },
                        set: { groupCondition.matchMode = ($0 ? .all : .any) }
                    ),
                    toggleOnTextKey: NSLocalizedString("∀", comment: ""),
                    toggleOnHelpTextKey: NSLocalizedString("Match all conditions", comment: ""),
                    toggleOffTextKey: NSLocalizedString("∃", comment: ""),
                    toggleOffHelpTextKey: NSLocalizedString("Match any conditions", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: Binding(
                        get: { groupCondition.isInverted },
                        set: { groupCondition.isInverted = $0 }
                    ),
                    toggleOnSystemImage: "minus.circle.fill",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: NSLocalizedString("Matching is Inverted", comment: ""),
                    toggleOffSystemImage: "largecircle.fill.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: NSLocalizedString("Matching is not Inverted", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: Binding(
                        get: { groupCondition.defaultResult },
                        set: { groupCondition.defaultResult = $0 }
                    ),
                    toggleOnSystemImage: "star.fill",
                    toggleOnSystemColor: .yellow,
                    toggleOnHelpTextKey: NSLocalizedString("Default to True when the Field is not Found", comment: ""),
                    toggleOffSystemImage: "star",
                    toggleOffSystemColor: .yellow,
                    toggleOffHelpTextKey: NSLocalizedString("Default to False when the Field is not Found", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: Binding(
                        get: { groupCondition.isDisabled },
                        set: { groupCondition.isDisabled = $0 }
                    ),
                    toggleOnSystemImage: "pause.circle",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: NSLocalizedString("This Condition is Disabled", comment: ""),
                    toggleOffSystemImage: "dot.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: NSLocalizedString("This Condition is Enabled", comment: "")
                )
                
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
    
    private func removeCondtion(_ condition: Condition) {
        ConditionListHelper.removeCondition(conditionId: condition.id, conditions: &groupCondition.conditions)
    }
    
    private func editCondtion(_ condition: Condition) {
        ConditionListHelper.openConditionDetailWindow(condition: condition) { savedCondition in
            ConditionListHelper.replaceCondtion(condition: savedCondition, conditions: &groupCondition.conditions, replacing: condition.id)
        }
    }
    
    private func moveCondtionLeft(_ condition: Condition) {
        ConditionListHelper.moveConditionLeft(conditionId: condition.id, conditions: &groupCondition.conditions)
    }
    
    private func moveCondtionRight(_ condition: Condition) {
        ConditionListHelper.moveConditionRight(conditionId: condition.id, conditions: &groupCondition.conditions)
    }
    
    private func addCondition() {
        ConditionListHelper.openConditionDetailWindow { condition in
            ConditionListHelper.addCondition(condition: condition, conditions: &groupCondition.conditions, insertAt: selectedItem)
        }
    }
    
    private func removeSelectedCondition() {
        forEachSelectedCondition(action: removeCondtion(_:))
    }
    
    private func editSelectedCondition() {
        forEachSelectedCondition(action: editCondtion(_:))
    }
    
    private func moveSelectedConditionsLeft() {
        forEachSelectedCondition(byOrder: true, reverseOrder: false, action: moveCondtionLeft(_:))
    }
    
    private func moveSelectedConditionsRight() {
        forEachSelectedCondition(byOrder: true, reverseOrder: true, action: moveCondtionRight(_:))
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
    
    static func addCondition(condition: Condition, conditions: inout [Condition], insertAt conditionId: UUID?) {
        
        if let conditionId = conditionId, let index = conditions.firstIndex(where: { $0.id == conditionId }) {
            conditions.insert(condition, at: index)
        } else {
            conditions.append(condition)
        }
    }
    
    static func replaceCondtion(condition: Condition, conditions: inout [Condition], replacing conditionId: UUID) {
        
        if let index = conditions.firstIndex(where: { $0.id == conditionId }) {
            conditions[index] = condition
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
        .frame(height: 100)
}
