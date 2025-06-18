//
//  SymbolLabelButton.swift
//  TerminalMonitor
//
//  Created on 2025/6/18.
//

import SwiftUI

struct SymbolLabelButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    let symbolColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(titleKey, systemImage: systemImage)
                .symbolRenderingMode(.palette)
                .foregroundStyle(symbolColor)
        }
        .labelStyle(.titleAndIcon)
    }
}

#Preview {
    SymbolLabelButton(titleKey: "Start", systemImage: "play.fill", symbolColor: .green) {}
}
