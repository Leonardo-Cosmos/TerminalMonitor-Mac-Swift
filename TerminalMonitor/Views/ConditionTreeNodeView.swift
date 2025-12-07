//
//  ConditionTreeNodeView.swift
//  TerminalMonitor
//
//  Created on 2025/12/7.
//

import SwiftUI

struct ConditionTreeNodeView: View {
    
    @ObservedObject var viewModel: ConditionTreeNodeViewModel
    
    var body: some View {
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
        }
    }
}

#Preview {
    ConditionTreeNodeView(viewModel: ConditionTreeNodeViewModel(
        isInverted: false,
        defaultResult: false,
        isDisabled: false,
        matchMode: .all
    ))
}
