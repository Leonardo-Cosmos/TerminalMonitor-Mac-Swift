//
//  FieldConditionView.swift
//  TerminalMonitor
//
//  Created on 2025/9/26.
//

import SwiftUI

struct FieldConditionView: View {
    
    @ObservedObject var viewModel: FieldConditionViewModel
    
    var body: some View {
        HStack {
            HStack {
                Text("Key")
                TextField("", text: $viewModel.fieldKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Picker("", selection: $viewModel.matchOperator) {
                ForEach(TextMatchOperator.allCases) { matchOperator in
                    Text(matchOperator.description).tag(matchOperator)
                }
            }
            .pickerStyle(.menu)
            
            HStack {
                Text("Value")
                TextField("", text: $viewModel.targetValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack {
                
                SymbolButtonToggle(
                    toggle: Binding(
                        get: { viewModel.isInverted },
                        set: { viewModel.isInverted = $0 }
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
                        get: { viewModel.defaultResult },
                        set: { viewModel.defaultResult = $0 }
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
                        get: { viewModel.isDisabled },
                        set: { viewModel.isDisabled = $0 }
                    ),
                    toggleOnSystemImage: "pause.circle",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: NSLocalizedString("This Condition is Disabled", comment: ""),
                    toggleOffSystemImage: "dot.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: NSLocalizedString("This Condition is Enabled", comment: "")
                )
            }
        }
    }
}

class FieldConditionViewModel: ObservableObject {
    
    let id: UUID
    
    @Published var fieldKey: String
    
    @Published var matchOperator: TextMatchOperator
    
    @Published var targetValue: String
    
    @Published var isInverted: Bool
    
    @Published var defaultResult: Bool
    
    @Published var isDisabled: Bool
    
    init(id: UUID = UUID(),
         fieldKey: String = "",
         matchOperator: TextMatchOperator = .contains,
         targetValue: String = "",
         isInverted: Bool = false,
         defaultResult: Bool = false,
         isDisabled: Bool = false) {
        self.id = id
        self.fieldKey = fieldKey
        self.matchOperator = matchOperator
        self.targetValue = targetValue
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
    }
    
    func to(_ fieldCondition: FieldCondition) {
        fieldCondition.fieldKey = fieldKey
        fieldCondition.matchOperator = matchOperator
        fieldCondition.targetValue = targetValue
        fieldCondition.isInverted = isInverted
        fieldCondition.defaultResult = defaultResult
        fieldCondition.isDisabled = isDisabled
    }
    
    func to() -> FieldCondition {
        FieldCondition(
            id: id,
            fieldKey: fieldKey,
            matchOperator: matchOperator,
            targetValue: targetValue,
            isInverted: isInverted,
            defaultResult: defaultResult,
            isDisabled: isDisabled,
        )
    }
    
    static func from(_ fieldCondition: FieldCondition) -> FieldConditionViewModel {
        FieldConditionViewModel(
            id: fieldCondition.id,
            fieldKey: fieldCondition.fieldKey,
            matchOperator: fieldCondition.matchOperator,
            targetValue: fieldCondition.targetValue,
            isInverted: fieldCondition.isInverted,
            defaultResult: fieldCondition.defaultResult,
            isDisabled: fieldCondition.isDisabled,
        )
    }
}

#Preview {
    FieldConditionView(
        viewModel: FieldConditionViewModel.from(previewFieldConditions()[0])
    )
}
