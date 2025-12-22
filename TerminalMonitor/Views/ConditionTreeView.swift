//
//  ConditionTreeView.swift
//  TerminalMonitor
//
//  Created on 2025/12/7.
//

import SwiftUI

struct ConditionTreeView: View {
    
    @Binding var matchMode: GroupMatchMode
    
    @Binding var isInverted: Bool
    
    @Binding var defaultResult: Bool
    
    @Binding var isDisabled: Bool
    
    @Binding var rootConditions: [ConditionTreeNodeViewModel]
    
    @State private var selectedId: UUID?
    
    @State private var nodeIdDict: [UUID: ConditionTreeNodeViewModel] = [:]
    
    var body: some View {
        VStack {
            HStack {
                TextButtonToggle(
                    toggle: Binding(
                        get: { matchMode == .all },
                        set: { matchMode = ($0 ? .all : .any) }
                    ),
                    toggleOnTextKey: NSLocalizedString("∀", comment: ""),
                    toggleOnHelpTextKey: NSLocalizedString("Match all conditions", comment: ""),
                    toggleOffTextKey: NSLocalizedString("∃", comment: ""),
                    toggleOffHelpTextKey: NSLocalizedString("Match any conditions", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: $isInverted,
                    toggleOnSystemImage: "minus.circle.fill",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: NSLocalizedString("Matching is Inverted", comment: ""),
                    toggleOffSystemImage: "largecircle.fill.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: NSLocalizedString("Matching is not Inverted", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: $defaultResult,
                    toggleOnSystemImage: "star.fill",
                    toggleOnSystemColor: .yellow,
                    toggleOnHelpTextKey: NSLocalizedString("Default to True when the Field is not Found", comment: ""),
                    toggleOffSystemImage: "star",
                    toggleOffSystemColor: .yellow,
                    toggleOffHelpTextKey: NSLocalizedString("Default to False when the Field is not Found", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: $isDisabled,
                    toggleOnSystemImage: "pause.circle",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: NSLocalizedString("This Condition is Disabled", comment: ""),
                    toggleOffSystemImage: "dot.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: NSLocalizedString("This Condition is Enabled", comment: "")
                )
                
                Spacer()
                
                Button("Add", systemImage: "plus") {
                    addCondition()
                }
                .labelStyle(.iconOnly)
                
                Button("Remove", systemImage: "minus") {
                    removeSelectedCondition()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedId == nil)
                
                Button("Move Up", systemImage: "arrowshape.up.fill") {
                    moveSelectedConditionsUp()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedId == nil)
                
                Button("Move Down", systemImage: "arrowshape.down.fill") {
                    moveSelectedConditionsDown()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedId == nil)
            }
            
            List(rootConditions, children: \.conditions, selection: $selectedId) { condition in
                if let fieldCondition = condition.fieldCondition {
                    FieldConditionView(viewModel: fieldCondition)
                } else {
                    ConditionTreeNodeView(viewModel: condition)
                }
            }
        }
    }
    
    private func addCondition() {
        
        let newCondition = ConditionTreeNodeViewModel(fieldCondition: FieldConditionViewModel())
        nodeIdDict[newCondition.id] = newCondition
        
        var selectedCondition: ConditionTreeNodeViewModel? = nil
        if let selectedId = selectedId {
            selectedCondition = nodeIdDict[selectedId]
        }
        
        if let parentCondition = selectedCondition?.parent {
            parentCondition.conditions = ConditionTreeHelper.addCondition(
                condition: newCondition, conditions: parentCondition.conditions!, replacing: selectedId)
        } else {
            rootConditions = ConditionTreeHelper.addCondition(condition: newCondition, conditions: rootConditions, replacing: selectedId)
        }
    }
    
    private func removeSelectedCondition() {
        
        guard let selectedId = selectedId else {
            return
        }
         
        guard let selectedCondition = nodeIdDict[selectedId] else {
            return
        }
        
        if let parentCondition = selectedCondition.parent {
            parentCondition.conditions = ConditionTreeHelper.removeCondition(conditionId: selectedId, conditions: parentCondition.conditions!)
        } else {
            rootConditions = ConditionTreeHelper.removeCondition(conditionId: selectedId, conditions: rootConditions)
        }
        
        nodeIdDict[selectedId] = nil
    }
    
    private func moveSelectedConditionsUp() {
        
        guard let selectedId = selectedId else {
            return
        }
         
        guard let selectedCondition = nodeIdDict[selectedId] else {
            return
        }
        
        if let parentCondition = selectedCondition.parent {
            parentCondition.conditions = ConditionTreeHelper.moveConditionUp(conditionId: selectedId, conditions: parentCondition.conditions!)
        } else {
            rootConditions = ConditionTreeHelper.moveConditionUp(conditionId: selectedId, conditions: rootConditions)
        }
    }
    
    private func moveSelectedConditionsDown() {
        
        guard let selectedId = selectedId else {
            return
        }
         
        guard let selectedCondition = nodeIdDict[selectedId] else {
            return
        }
        
        if let parentCondition = selectedCondition.parent {
            parentCondition.conditions = ConditionTreeHelper.moveConditionDown(conditionId: selectedId, conditions: parentCondition.conditions!)
        } else {
            rootConditions = ConditionTreeHelper.moveConditionDown(conditionId: selectedId, conditions: rootConditions)
        }
    }
}

class ConditionTreeNodeViewModel: ObservableObject, Identifiable {
    
    let id: UUID
    
    let parent: ConditionTreeNodeViewModel?
    
    @Published var isInverted: Bool
    
    @Published var defaultResult: Bool
    
    @Published var isDisabled: Bool
    
    @Published var matchMode: GroupMatchMode
    
    @Published var conditions: [ConditionTreeNodeViewModel]?
    
    @Published var fieldCondition: FieldConditionViewModel?
    
    init(id: UUID, parent: ConditionTreeNodeViewModel?, isInverted: Bool, defaultResult: Bool, isDisabled: Bool, matchMode: GroupMatchMode, conditions: [ConditionTreeNodeViewModel]?, fieldCondition: FieldConditionViewModel?) {
        self.id = id
        self.parent = parent
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
        self.matchMode = matchMode
        self.conditions = conditions
        self.fieldCondition = fieldCondition
    }
    
    convenience init(isInverted: Bool = false, defaultResult: Bool = false, isDisabled: Bool = false, matchMode: GroupMatchMode = .all, conditions: [ConditionTreeNodeViewModel]? = nil, fieldCondition: FieldConditionViewModel? = nil) {
        self.init(
            id: UUID(),
            parent: nil,
            isInverted: false,
            defaultResult: false,
            isDisabled: false,
            matchMode: matchMode,
            conditions: conditions,
            fieldCondition: fieldCondition,
        )
    }
}

struct ConditionTreeHelper {
    
    static func addCondition(condition: ConditionTreeNodeViewModel, conditions: [ConditionTreeNodeViewModel], replacing conditionId: UUID?) -> [ConditionTreeNodeViewModel] {
        
        var conditions = conditions
        
        if let conditionId = conditionId, let index = conditions.firstIndex(where: { $0.id == conditionId }) {
            conditions.insert(condition, at: index)
        } else {
            conditions.append(condition)
        }
        
        return conditions
    }
    
    static func removeCondition(conditionId: UUID, conditions: [ConditionTreeNodeViewModel]) -> [ConditionTreeNodeViewModel] {
        
        var conditions = conditions
        
        conditions.removeAll() { condition in condition.id == conditionId }
        
        return conditions
    }
    
    static func moveConditionUp(conditionId: UUID, conditions: [ConditionTreeNodeViewModel]) -> [ConditionTreeNodeViewModel] {
        
        var conditions = conditions
        
        guard let srcIndex = conditions.firstIndex(where: { $0.id == conditionId }) else {
            return conditions
        }
        
        let dstIndex = (srcIndex - 1 + conditions.count) % conditions.count
        
        let condition = conditions[srcIndex]
        conditions.remove(at: srcIndex)
        conditions.insert(condition, at: dstIndex)
        
        return conditions
    }
    
    static func moveConditionDown(conditionId: UUID, conditions: [ConditionTreeNodeViewModel]) -> [ConditionTreeNodeViewModel] {
        var conditions = conditions
        
        guard let srcIndex = conditions.firstIndex(where: { $0.id == conditionId }) else {
            return conditions
        }
        
        let dstIndex = (srcIndex + 1) % conditions.count
        
        let condition = conditions[srcIndex]
        conditions.remove(at: srcIndex)
        conditions.insert(condition, at: dstIndex)
        
        return conditions
    }
}

#Preview {
    ConditionTreeView(
        matchMode: .constant(.all),
        isInverted: .constant(false),
        defaultResult: .constant(false),
        isDisabled: .constant(false),
        rootConditions: .constant([
            ConditionTreeNodeViewModel(
                fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[0])
            ),
            ConditionTreeNodeViewModel(
                fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[1])
            ),
            ConditionTreeNodeViewModel(
                fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[2])
            ),
            ConditionTreeNodeViewModel(
                conditions: [
                    ConditionTreeNodeViewModel(
                        fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[0])
                    ),
                    ConditionTreeNodeViewModel(
                        fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[1])
                    ),
                    ConditionTreeNodeViewModel(
                        fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[2])
                    ),
                ]
            )
        ])
    )
}
