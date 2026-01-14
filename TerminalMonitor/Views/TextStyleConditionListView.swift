//
//  TextStyleConditionListView.swift
//  TerminalMonitor
//
//  Created on 2025/11/19.
//

import SwiftUI

struct TextStyleConditionListView: View {
    
    @Binding var styleConditions: [TextStyleConditionViewModel]
    
    @State private var selectedItems = Set<UUID>()
    
    var body: some View {
        VStack {
            HStack {
                SymbolButton(systemImage: "plus", symbolColor: .primary) {
                    addCondition()
                }
                
                SymbolButton(systemImage: "minus", symbolColor: .primary) {
                    removeSelectedCondition()
                }
                
                SymbolButton(systemImage: "arrowshape.up.fill", symbolColor: .primary) {
                    moveSelectedConditionsUp()
                }
                
                SymbolButton(systemImage: "arrowshape.down.fill", symbolColor: .primary) {
                    moveSelectedConditionsDown()
                }
                
                Spacer()
            }
            
            List(styleConditions, selection: $selectedItems) { styleCondition in
                TextStyleConditionView(viewModel: styleCondition)
                    .padding(.vertical, 2)
            }
        }
    }
    
    private func forEachSelectedCondition(byOrder: Bool = false, reverseOrder: Bool = false,
                                          action: (TextStyleConditionViewModel) -> Void) {
        var selectedConditions: [TextStyleConditionViewModel] = []
        for conditionId in selectedItems {
            if let selectedCondition = styleConditions.first(where: { $0.id == conditionId }) {
                selectedConditions.append(selectedCondition)
            }
        }
        
        if byOrder {
            selectedConditions.sort(by: { conditionX, conditionY in
                let indexX = styleConditions.firstIndex(where: { $0.id == conditionX.id }) ?? 0
                let indexY = styleConditions.firstIndex(where: { $0.id == conditionY.id }) ?? 0
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
        TextStyleConditionListHelper.addCondition(
            condition: TextStyleConditionViewModel(condition: FieldCondition(
                fieldKey: "",
                matchOperator: .none,
                targetValue: ""
            )),
            conditions: &styleConditions,
            replacing: nil
        )
    }
    
    private func removeSelectedCondition() {
        forEachSelectedCondition { selectedCondition in
            TextStyleConditionListHelper.removeCondition(
                conditionId: selectedCondition.id,
                conditions: &styleConditions
            )
        }
    }
    
    private func moveSelectedConditionsUp() {
        forEachSelectedCondition(byOrder: true, reverseOrder: false) { selectedCondition in
            TextStyleConditionListHelper.moveConditionUp(
                conditionId: selectedCondition.id,
                conditions: &styleConditions
            )
        }
    }
    
    private func moveSelectedConditionsDown() {
        forEachSelectedCondition(byOrder: true, reverseOrder: true) { selectedCondition in
            TextStyleConditionListHelper.moveConditionDown(
                conditionId: selectedCondition.id,
                conditions: &styleConditions
            )
        }
    }
}

struct TextStyleConditionListHelper {
    
    static func addCondition(condition: TextStyleConditionViewModel, conditions: inout [TextStyleConditionViewModel], replacing conditionId: UUID?) {
        
        if let conditionId = conditionId, let index = conditions.firstIndex(where: { $0.id == conditionId }) {
            conditions.insert(condition, at: index)
        } else {
            conditions.append(condition)
        }
    }
    
    static func removeCondition(conditionId: UUID, conditions: inout [TextStyleConditionViewModel]) {
        
        conditions.removeAll() { condition in condition.id == conditionId }
    }
    
    static func moveConditionUp(conditionId: UUID, conditions: inout [TextStyleConditionViewModel]) {
        guard let srcIndex = conditions.firstIndex(where: { $0.id == conditionId }) else {
            return
        }
        
        let dstIndex = (srcIndex - 1 + conditions.count) % conditions.count
        
        let condition = conditions[srcIndex]
        conditions.remove(at: srcIndex)
        conditions.insert(condition, at: dstIndex)
    }
    
    static func moveConditionDown(conditionId: UUID, conditions: inout [TextStyleConditionViewModel]) {
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
    TextStyleConditionListView(styleConditions: Binding.constant([
        TextStyleConditionViewModel(style: TextStyleViewModel(), inheritDefault: false, condition: previewFieldConditions()[0]),
        TextStyleConditionViewModel(style: TextStyleViewModel(), inheritDefault: false, condition: previewFieldConditions()[1]),
        TextStyleConditionViewModel(style: TextStyleViewModel(), inheritDefault: false, condition: previewFieldConditions()[2]),
    ]))
}
