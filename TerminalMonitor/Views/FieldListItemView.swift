//
//  FieldListItemView.swift
//  TerminalMonitor
//
//  Created on 2025/11/25.
//

import SwiftUI

struct FieldListItemView: View {
    
    @ObservedObject var fieldDisplayConfig: FieldDisplayConfig
    
    var onFieldClicked: (UUID) -> Void
    
    var buttonForeground: (UUID) -> Color
    
    var buttonBackground: (UUID) -> Color
    
    var body: some View {
        Button(action: { onFieldClicked(fieldDisplayConfig.id) }) {
            HStack {
                Text(fieldDisplayConfig.fieldDescription)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
            }
            .foregroundStyle(buttonForeground(fieldDisplayConfig.id))
            .background(buttonBackground(fieldDisplayConfig.id))
            .backgroundStyle(buttonBackground(fieldDisplayConfig.id))
            .opacity(fieldDisplayConfig.hidden ? 0.5 : 1.0)
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
    FieldListItemView(
        fieldDisplayConfig: previewFieldDisplayConfigs()[0],
        onFieldClicked: { _ in },
        buttonForeground: { _ in Color(nsColor: NSColor.controlTextColor) },
        buttonBackground: { _ in Color(nsColor: NSColor.controlColor) }
    )
}
