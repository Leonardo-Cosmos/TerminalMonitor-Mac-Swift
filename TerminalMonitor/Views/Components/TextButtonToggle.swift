//
//  TextButtonToggle.swift
//  TerminalMonitor
//
//  Created on 2025/11/5.
//

import SwiftUI

struct TextButtonToggle: View {
    
    @Binding var toggle: Bool
    
    let toggleOnTextKey: String
    
    let toggleOnHelpTextKey: String?
    
    let toggleOffTextKey: String
    
    let toggleOffHelpTextKey: String?
    
    var body: some View {
        ButtonToggle(
            toggle: $toggle,
            toggleOnContent: {
                Text(toggleOnTextKey)
                    .padding(.top, -1)
                    .padding(.bottom, 1)
            },
            toggleOnHelpTextKey: toggleOnHelpTextKey,
            toggleOffContent: {
                Text(toggleOffTextKey)
                    .padding(.top, -1)
                    .padding(.bottom, 1)
            },
            toggleOffHelpTextKey: toggleOffHelpTextKey
        )
    }
}

#Preview {
    TextButtonToggle(
        toggle: Binding.constant(true),
        toggleOnTextKey: "Yes",
        toggleOnHelpTextKey: "On",
        toggleOffTextKey: "No",
        toggleOffHelpTextKey: "Off"
    )
    .frame(width: 50, height: 50)
}
