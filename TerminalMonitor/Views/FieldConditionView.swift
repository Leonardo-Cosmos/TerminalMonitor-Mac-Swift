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
            
            if viewModel.isInverted {
                SymbolButton(systemImage: "minus.circle.fill", symbolColor: .red) {
                    viewModel.isInverted = false
                }
            } else {
                SymbolButton(systemImage: "largecircle.fill.circle", symbolColor: .green) {
                    viewModel.isInverted = true
                }
            }
            
            if viewModel.defaultResult {
                SymbolButton(systemImage: "star.fill", symbolColor: .yellow) {
                    viewModel.defaultResult = false
                }
            } else {
                SymbolButton(systemImage: "star", symbolColor: .yellow) {
                    viewModel.defaultResult = true
                }
            }
            
            if viewModel.isDisabled {
                SymbolButton(systemImage: "pause.circle", symbolColor: .red) {
                    viewModel.isDisabled = false
                }
            } else {
                SymbolButton(systemImage: "dot.circle", symbolColor: .green) {
                    viewModel.isDisabled = true
                }
            }
        }
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
