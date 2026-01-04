//
//  ConditionTreeView.swift
//  TerminalMonitor
//
//  Created on 2025/12/7.
//

import SwiftUI
import os

struct ConditionTreeView: View {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Self.self)
    )
    
    @ObservedObject var viewModel: ConditionTreeNodeViewModel
    
    @State private var selectedId: UUID?
    
    @State private var nodeIdDict: [UUID: ConditionTreeNodeViewModel] = [:]
    
    var body: some View {
        VStack {
            HStack {
                TextButtonToggle(
                    toggle: Binding(
                        get: { viewModel.matchMode == .all },
                        set: { viewModel.matchMode = ($0 ? .all : .any) }
                    ),
                    toggleOnTextKey: NSLocalizedString("∀", comment: ""),
                    toggleOnHelpTextKey: NSLocalizedString("Match all conditions", comment: ""),
                    toggleOffTextKey: NSLocalizedString("∃", comment: ""),
                    toggleOffHelpTextKey: NSLocalizedString("Match any conditions", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: $viewModel.isInverted,
                    toggleOnSystemImage: "minus.circle.fill",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: NSLocalizedString("Matching is Inverted", comment: ""),
                    toggleOffSystemImage: "largecircle.fill.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: NSLocalizedString("Matching is not Inverted", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: $viewModel.defaultResult,
                    toggleOnSystemImage: "star.fill",
                    toggleOnSystemColor: .yellow,
                    toggleOnHelpTextKey: NSLocalizedString("Default to True when the Field is not Found", comment: ""),
                    toggleOffSystemImage: "star",
                    toggleOffSystemColor: .yellow,
                    toggleOffHelpTextKey: NSLocalizedString("Default to False when the Field is not Found", comment: "")
                )
                
                SymbolButtonToggle(
                    toggle: $viewModel.isDisabled,
                    toggleOnSystemImage: "pause.circle",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: NSLocalizedString("This Condition is Disabled", comment: ""),
                    toggleOffSystemImage: "dot.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: NSLocalizedString("This Condition is Enabled", comment: "")
                )
                
                Spacer()
                
                Button("Add Field", systemImage: "plus") {
                    addFieldCondition()
                }
                .labelStyle(.iconOnly)
                
                Button(action: { addGroupCondition() }) {
                    Label {
                        Text("Add Group")
                    } icon: {
                        HStack {
                            Image(systemName: "plus")
                            Text("{}")
                        }
                    }
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
            
            List(viewModel.conditions!, children: \.conditions, selection: $selectedId) { condition in
                if let fieldCondition = condition.fieldCondition {
                    FieldConditionView(viewModel: fieldCondition)
                } else {
                    ConditionTreeNodeView(viewModel: condition)
                }
            }
        }
        .onAppear {
            initNodeIdDict(condition: viewModel)
        }
    }
    
    private func initNodeIdDict(condition: ConditionTreeNodeViewModel) {
        nodeIdDict[condition.id] = condition
        condition.conditions?.forEach { initNodeIdDict(condition: $0) }
    }
    
    private func addFieldCondition() {
        addCondition(newCondition: ConditionTreeNodeViewModel(
            fieldCondition: FieldConditionViewModel()
        ))
    }
    
    private func addGroupCondition() {
        addCondition(newCondition: ConditionTreeNodeViewModel(
            conditions: []
        ))
    }
    
    private func addCondition(newCondition: ConditionTreeNodeViewModel) {
        
        nodeIdDict[newCondition.id] = newCondition
        
        var selectedCondition: ConditionTreeNodeViewModel? = nil
        if let selectedId = selectedId {
            Self.logger.debug("Selected node id: \(selectedId)")
            selectedCondition = nodeIdDict[selectedId]
        }
        
        if let selectedCondition = selectedCondition {
            // There is a selected node
            Self.logger.debug("Selected node: \(selectedCondition.id)")
            
            if selectedCondition.conditions != nil {
                // The selected node is group condition
                Self.logger.debug("Selected node is a group condition")
                ConditionTreeHelper.addCondition(
                    condition: newCondition,
                    parentCondition: selectedCondition,
                    replacing: nil
                )
            } else {
                // The selected node is field condition
                Self.logger.debug("Selected node is a field condition")
                let parentCondition = selectedCondition.parent!
                ConditionTreeHelper.addCondition(
                    condition: newCondition,
                    parentCondition: parentCondition,
                    replacing: selectedId
                )
            }
        } else {
            // There is not a selected node
            Self.logger.debug("No selected node")
            ConditionTreeHelper.addCondition(
                condition: newCondition,
                parentCondition: viewModel,
                replacing: nil
            )
        }
    }
    
    private func removeSelectedCondition() {
        
        guard let selectedId = selectedId else {
            return
        }
        
        guard let selectedCondition = nodeIdDict[selectedId] else {
            return
        }
        
        let parentCondition = selectedCondition.parent!
        ConditionTreeHelper.removeCondition(
            conditionId: selectedId,
            parentCondition: parentCondition
        )
        
        
        nodeIdDict[selectedId] = nil
    }
    
    private func moveSelectedConditionsUp() {
        
        guard let selectedId = selectedId else {
            return
        }
        
        guard let selectedCondition = nodeIdDict[selectedId] else {
            return
        }
        
        let parentCondition = selectedCondition.parent!
        ConditionTreeHelper.moveConditionUp(
            conditionId: selectedId,
            parentCondition: parentCondition
        )
    }
    
    private func moveSelectedConditionsDown() {
        
        guard let selectedId = selectedId else {
            return
        }
        
        guard let selectedCondition = nodeIdDict[selectedId] else {
            return
        }
        
        let parentCondition = selectedCondition.parent!
        ConditionTreeHelper.moveConditionDown(
            conditionId: selectedId,
            parentCondition: parentCondition
        )
    }
}

class ConditionTreeNodeViewModel: ObservableObject, Identifiable {
    
    let id: UUID
    
    var parent: ConditionTreeNodeViewModel?
    
    @Published var isInverted: Bool
    
    @Published var defaultResult: Bool
    
    @Published var isDisabled: Bool
    
    @Published var matchMode: GroupMatchMode
    
    @Published var conditions: [ConditionTreeNodeViewModel]? {
        didSet {
            if conditions != nil {
                fieldCondition = nil
            }
        }
    }
    
    @Published var fieldCondition: FieldConditionViewModel? {
        didSet {
            if fieldCondition != nil {
                conditions = nil
            }
        }
    }
    
    init(id: UUID = UUID(),
         parent: ConditionTreeNodeViewModel? = nil,
         isInverted: Bool = false,
         defaultResult: Bool = false,
         isDisabled: Bool = false,
         matchMode: GroupMatchMode = .all,
         conditions: [ConditionTreeNodeViewModel]? = nil,
         fieldCondition: FieldConditionViewModel? = nil) {
        self.id = id
        self.parent = parent
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
        self.matchMode = matchMode
        self.conditions = conditions
        self.fieldCondition = fieldCondition
    }
    
    func to() -> Condition {
        if let fieldCondition = fieldCondition {
            return fieldCondition.to()
        } else {
            return GroupCondition(
                id: id,
                name: nil,
                matchMode: matchMode,
                conditions: conditions?.map { $0.to() } ?? [],
                isInverted: isInverted,
                defaultResult: defaultResult,
                isDisabled: isDisabled,
            )
        }
    }
    
    static func from(_ groupCondtion: GroupCondition) -> ConditionTreeNodeViewModel {
        from(groupCondtion, parent: nil)
    }
    
    private static func from(_ condition: Condition, parent: ConditionTreeNodeViewModel?) -> ConditionTreeNodeViewModel {
        if let fieldCondition = condition as? FieldCondition {
            from(fieldCondition, parent: parent)
        } else if let groupCondition = condition as? GroupCondition {
            from(groupCondition, parent: parent)
        } else {
            fatalError("Unknown condtion type: \(type(of: condition))")
        }
    }
    
    private static func from(_ fieldCondition: FieldCondition, parent: ConditionTreeNodeViewModel?) -> ConditionTreeNodeViewModel {
        ConditionTreeNodeViewModel(
            parent: parent,
            fieldCondition: FieldConditionViewModel.from(fieldCondition)
        )
    }
    
    private static func from(_ groupCondition: GroupCondition, parent: ConditionTreeNodeViewModel?) -> ConditionTreeNodeViewModel {
        let viewModel = ConditionTreeNodeViewModel(
            id: groupCondition.id,
            parent: parent,
            isInverted: groupCondition.isInverted,
            defaultResult: groupCondition.defaultResult,
            isDisabled: groupCondition.isDisabled,
            matchMode: groupCondition.matchMode,
        )
        viewModel.conditions = groupCondition.conditions.map { condition in from(condition, parent: viewModel) }
        return viewModel
    }
}

struct ConditionTreeHelper {
    
    static func addCondition(condition: ConditionTreeNodeViewModel, parentCondition: ConditionTreeNodeViewModel, replacing conditionId: UUID?) {
        
        var conditions = parentCondition.conditions!
        
        if let conditionId = conditionId, let index = conditions.firstIndex(where: { $0.id == conditionId }) {
            conditions.insert(condition, at: index)
        } else {
            conditions.append(condition)
        }
        
        condition.parent = parentCondition
        parentCondition.conditions = conditions
    }
    
    static func removeCondition(conditionId: UUID, parentCondition: ConditionTreeNodeViewModel) {
        
        var conditions = parentCondition.conditions!
        
        conditions.removeAll() { condition in condition.id == conditionId }
        
        parentCondition.conditions = conditions
    }
    
    static func moveConditionUp(conditionId: UUID, parentCondition: ConditionTreeNodeViewModel) {
        
        var conditions = parentCondition.conditions!
        
        guard let srcIndex = conditions.firstIndex(where: { $0.id == conditionId }) else {
            return
        }
        
        let dstIndex = (srcIndex - 1 + conditions.count) % conditions.count
        
        let condition = conditions[srcIndex]
        conditions.remove(at: srcIndex)
        conditions.insert(condition, at: dstIndex)
        
        parentCondition.conditions = conditions
    }
    
    static func moveConditionDown(conditionId: UUID, parentCondition: ConditionTreeNodeViewModel) {
        
        var conditions = parentCondition.conditions!
        
        guard let srcIndex = conditions.firstIndex(where: { $0.id == conditionId }) else {
            return
        }
        
        let dstIndex = (srcIndex + 1) % conditions.count
        
        let condition = conditions[srcIndex]
        conditions.remove(at: srcIndex)
        conditions.insert(condition, at: dstIndex)
        
        parentCondition.conditions = conditions
    }
}

#Preview {
//    ConditionTreeView(
//        matchMode: .constant(.all),
//        isInverted: .constant(false),
//        defaultResult: .constant(false),
//        isDisabled: .constant(false),
//        rootConditions: .constant([
//            ConditionTreeNodeViewModel(
//                fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[0])
//            ),
//            ConditionTreeNodeViewModel(
//                fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[1])
//            ),
//            ConditionTreeNodeViewModel(
//                fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[2])
//            ),
//            ConditionTreeNodeViewModel(
//                conditions: [
//                    ConditionTreeNodeViewModel(
//                        fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[0])
//                    ),
//                    ConditionTreeNodeViewModel(
//                        fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[1])
//                    ),
//                    ConditionTreeNodeViewModel(
//                        fieldCondition: FieldConditionViewModel.from(previewFieldConditions()[2])
//                    ),
//                ]
//            )
//        ])
//    )
}
