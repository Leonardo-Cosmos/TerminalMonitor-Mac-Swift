//
//  ConditionListItemView.swift
//  TerminalMonitor
//
//  Created on 2025/11/25.
//

import SwiftUI

struct ConditionListItemView: View {
    
    @ObservedObject var condition: Condition
    
    var onConditionClicked: (UUID) -> Void
    
    var buttonForeground: (UUID) -> Color
    
    var buttonBackground: (UUID) -> Color
    
    var body: some View {
        Button(action: { onConditionClicked(condition.id)}) {
            HStack {
                Text(condition.conditionDescription)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    SymbolButtonToggle(
                        toggle: Binding(
                            get: { condition.isInverted },
                            set: { condition.isInverted = $0 }
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
                            get: { condition.defaultResult },
                            set: { condition.defaultResult = $0 }
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
                            get: { condition.isDisabled },
                            set: { condition.isDisabled = $0 }
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
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .foregroundStyle(buttonForeground(condition.id))
            .background(buttonBackground(condition.id))
            .backgroundStyle(buttonBackground(condition.id))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(nsColor: NSColor.lightGray), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ConditionListItemView(
        condition: previewConditions()[0],
        onConditionClicked: { _ in },
        buttonForeground: { _ in Color(nsColor: NSColor.controlTextColor) },
        buttonBackground: { _ in Color(nsColor: NSColor.controlColor) }
    )
}
