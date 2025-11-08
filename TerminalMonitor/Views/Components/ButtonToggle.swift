//
//  ButtonToggle.swift
//  TerminalMonitor
//
//  Created on 2025/11/3.
//

import SwiftUI

struct ButtonToggle<Label1: View, Label2: View>: View {
    
    @Binding var toggle: Bool
    
    let toggleOnContent: () -> Label1
    
    let toggleOnHelpTextKey: String?
    
    let toggleOffContent: () -> Label2
    
    let toggleOffHelpTextKey: String?
    
    var body: some View {
        Button(action: { toggle.toggle() }) {
            if toggle {
                toggleOnContent()
            } else {
                toggleOffContent()
            }
        }
        .buttonStyle(.plain)
        .help((toggle ? toggleOnHelpTextKey : toggleOffHelpTextKey) ?? "")
    }
}

#Preview {
    ButtonToggle(
        toggle: Binding.constant(true),
        toggleOnContent: {
            Text("On")
        },
        toggleOnHelpTextKey: "On",
        toggleOffContent: {
            Text("Off")
        },
        toggleOffHelpTextKey: "Off"
    )
}
