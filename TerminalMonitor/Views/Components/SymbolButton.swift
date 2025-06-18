//
//  SymbolButton.swift
//  TerminalMonitor
//
//  Created on 2025/6/18.
//

import SwiftUI

struct SymbolButton: View {
    let systemImage: String
    let symbolColor: Color
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundStyle(symbolColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isHovering ? .gray : .clear, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    SymbolButton(systemImage: "play", symbolColor: .black) {}
}
