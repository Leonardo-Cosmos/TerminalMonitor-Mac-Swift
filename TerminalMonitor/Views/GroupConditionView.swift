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
                viewModel: viewModel.rootGroupConditionViewModel
            )
        }
    }
}

class GroupConditionViewModel: ObservableObject {
    
    let id: UUID
    
    @Published var name: String
    
    @Published var rootGroupConditionViewModel: ConditionTreeNodeViewModel
    
    init(id: UUID = UUID(),
         name: String = "",
         rootGroupCondition: ConditionTreeNodeViewModel = ConditionTreeNodeViewModel(conditions: [])) {
        self.id = id
        self.name = name
        self.rootGroupConditionViewModel = rootGroupCondition
    }
    
    func to(_ groupCondition: GroupCondition) {
        let rootGroupCondtion = rootGroupConditionViewModel.to() as! GroupCondition
        groupCondition.name = name
        groupCondition.matchMode = rootGroupCondtion.matchMode
        groupCondition.conditions = rootGroupCondtion.conditions
        groupCondition.isInverted = rootGroupCondtion.isInverted
        groupCondition.defaultResult = rootGroupCondtion.defaultResult
        groupCondition.isDisabled = rootGroupCondtion.isDisabled
    }
    
    func to() -> GroupCondition {
        let rootGroupCondition = rootGroupConditionViewModel.to() as! GroupCondition
        return GroupCondition(
            id: id,
            name: name,
            matchMode: rootGroupCondition.matchMode,
            conditions: rootGroupCondition.conditions,
            isInverted: rootGroupCondition.isInverted,
            defaultResult: rootGroupCondition.defaultResult,
            isDisabled: rootGroupCondition.isDisabled,
        )
    }
    
    static func from(_ groupCondition: GroupCondition) -> GroupConditionViewModel {
        GroupConditionViewModel(
            id: groupCondition.id,
            name: groupCondition.name ?? "",
            rootGroupCondition: ConditionTreeNodeViewModel.from(groupCondition),
        )
    }
}

#Preview {
    GroupConditionView(
        viewModel: GroupConditionViewModel.from(previewGroupCondition())
    )
    .padding()
}
