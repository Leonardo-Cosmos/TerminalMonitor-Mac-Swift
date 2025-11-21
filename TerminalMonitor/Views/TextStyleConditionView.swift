//
//  TextStyleConditionView.swift
//  TerminalMonitor
//
//  Created on 2025/11/17.
//

import SwiftUI

struct TextStyleConditionView: View {
    
    @ObservedObject var viewModel: TextStyleConditionViewModel
    
    @State var conditionDescription: String = ""
    
    var body: some View {
        VStack {
            GroupBox(label: EmptyView()) {
                HStack {
                    Button(viewModel.condition.conditionDescription) {
                        ConditionDetailWindowController.openWindow(for: $viewModel.condition) { condition in
                            conditionDescription = condition.conditionDescription
                        }
                    }
                    .onAppear() {
                        conditionDescription = viewModel.condition.conditionDescription
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                TextStyleView(viewModel: viewModel.style)
            }
        }
    }
}

class TextStyleConditionViewModel: Identifiable, ObservableObject {
    
    let id: UUID
    
    @Published var style: TextStyleViewModel
    
    @Published var condition: Condition
    
    init(id: UUID, style: TextStyleViewModel, condition: Condition) {
        self.id = id
        self.style = style
        self.condition = condition
    }
    
    convenience init(style: TextStyleViewModel, condition: Condition) {
        self.init(
            id: UUID(),
            style: style,
            condition: condition,
        )
    }
    
    convenience init(condition: Condition) {
        self.init(
            style: TextStyleViewModel(),
            condition: condition
        )
    }
    
    func to(_ textStyleCondition: TextStyleCondition) {
        style.to(textStyleCondition.style)
        textStyleCondition.condition = condition as! FieldCondition
    }
    
    func to() -> TextStyleCondition {
        TextStyleCondition(
            style: style.to(),
            condition: condition as! FieldCondition
        )
    }
    
    static func from(_ textStyleCondition: TextStyleCondition) -> TextStyleConditionViewModel {
        TextStyleConditionViewModel(
            style: TextStyleViewModel.from(textStyleCondition.style),
            condition: textStyleCondition.condition,
        )
    }
}

#Preview {
    TextStyleConditionView(viewModel: TextStyleConditionViewModel(
        condition: FieldCondition(fieldKey: "plaintext", matchOperator: .equals, targetValue: "{}")
    ))
}
