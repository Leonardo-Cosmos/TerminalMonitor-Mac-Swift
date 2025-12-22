//
//  GroupConditionView.swift
//  TerminalMonitor
//
//  Created on 2025/12/1.
//

import SwiftUI

struct GroupConditionView: View {
    
    @ObservedObject var viewModel: GroupConditionViewModel
    
    @State private var selectedId: UUID?
    
    var body: some View {
        VStack {
            HStack {
                Text("Name")
                TextField("", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            ConditionTreeView(
                matchMode: $viewModel.matchMode,
                isInverted: $viewModel.isInverted,
                defaultResult: $viewModel.defaultResult,
                isDisabled: $viewModel.isDisabled,
                rootConditions: $viewModel.conditions
            )
        }
    }
}

class GroupConditionViewModel: ObservableObject {
    
    @Published var name: String
    
    @Published var matchMode: GroupMatchMode
    
    @Published var isInverted: Bool
    
    @Published var defaultResult: Bool
    
    @Published var isDisabled: Bool
    
    @Published var conditions: [ConditionTreeNodeViewModel]
    
    init(name: String = "", matchMode: GroupMatchMode = .all, isInverted: Bool = false, defaultResult: Bool = false, isDisabled: Bool = false, conditions: [ConditionTreeNodeViewModel] = []) {
        self.name = name
        self.matchMode = matchMode
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
        self.conditions = conditions
    }
}

#Preview {
    GroupConditionView(viewModel: GroupConditionViewModel(
            isInverted: true,
            defaultResult: true,
            isDisabled: true,
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
            ]
        ))
    .padding()
}
