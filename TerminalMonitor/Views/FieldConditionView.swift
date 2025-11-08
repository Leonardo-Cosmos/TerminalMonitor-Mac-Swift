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
                    toggleOnHelpTextKey: "Matching is Inverted",
                    toggleOffSystemImage: "largecircle.fill.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: "Matching is not Inverted"
                )
                
                SymbolButtonToggle(
                    toggle: Binding(
                        get: { viewModel.defaultResult },
                        set: { viewModel.defaultResult = $0 }
                    ),
                    toggleOnSystemImage: "star.fill",
                    toggleOnSystemColor: .yellow,
                    toggleOnHelpTextKey: "Default to True when the Field is not Found",
                    toggleOffSystemImage: "star",
                    toggleOffSystemColor: .yellow,
                    toggleOffHelpTextKey: "Default to False when the Field is not Found"
                )
                
                SymbolButtonToggle(
                    toggle: Binding(
                        get: { viewModel.isDisabled },
                        set: { viewModel.isDisabled = $0 }
                    ),
                    toggleOnSystemImage: "pause.circle",
                    toggleOnSystemColor: .red,
                    toggleOnHelpTextKey: "This Condition is Disabled",
                    toggleOffSystemImage: "dot.circle",
                    toggleOffSystemColor: .green,
                    toggleOffHelpTextKey: "This Condition is Enabled"
                )
            }
        }
        .padding()
    }
}

class FieldConditionViewModel: ObservableObject {
    
    @Published var fieldKey: String
    
    @Published var matchOperator: TextMatchOperator
    
    @Published var targetValue: String
    
    @Published var isInverted: Bool
    
    @Published var defaultResult: Bool
    
    @Published var isDisabled: Bool
    
    init(fieldKey: String, matchOperator: TextMatchOperator, targetValue: String, isInverted: Bool, defaultResult: Bool, isDisabled: Bool) {
        self.fieldKey = fieldKey
        self.matchOperator = matchOperator
        self.targetValue = targetValue
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
    }
    
    convenience init(fieldKey: String, matchOperator: TextMatchOperator, targetValue: String) {
        self.init(
            fieldKey: fieldKey,
            matchOperator: matchOperator,
            targetValue: targetValue,
            isInverted: false,
            defaultResult: false,
            isDisabled: false,
        )
    }
    
    convenience init() {
        self.init(
            fieldKey: "",
            matchOperator: .contains,
            targetValue: "",
        )
    }
}

#Preview {
    FieldConditionView(
        viewModel: FieldConditionViewModel(
            fieldKey: "key",
            matchOperator: .contains,
            targetValue: "value"
        )
    )
}
