//
//  SymbolButtonToggle.swift
//  TerminalMonitor
//
//  Created on 2025/11/3.
//

import SwiftUI

struct SymbolButtonToggle: View {
    
    @Binding var toggle: Bool
    
    let toggleOnSystemImage: String
    
    let toggleOnSystemColor: Color
    
    let toggleOnHelpTextKey: String?
    
    let toggleOffSystemImage: String
    
    let toggleOffSystemColor: Color
    
    let toggleOffHelpTextKey: String?
    
    var body: some View {
        ButtonToggle(
            toggle: $toggle,
            toggleOnContent: {
                Image(systemName: toggleOnSystemImage)
                    .foregroundStyle(toggleOnSystemColor)
            },
            toggleOnHelpTextKey: toggleOnHelpTextKey,
            toggleOffContent: {
                Image(systemName: toggleOffSystemImage)
                    .foregroundStyle(toggleOffSystemColor)
            },
            toggleOffHelpTextKey: toggleOffHelpTextKey
        )
    }
}

#Preview {
    SymbolButtonToggle(
        toggle: Binding.constant(true),
        toggleOnSystemImage: "plus",
        toggleOnSystemColor: .green,
        toggleOnHelpTextKey: "On",
        toggleOffSystemImage: "minus",
        toggleOffSystemColor: .red,
        toggleOffHelpTextKey: "Off"
    )
}
