//
//  TextInputView.swift
//  TerminalMonitor
//
//  Created on 2025/9/9.
//

import SwiftUI

struct TextInputView: View {
    
    @Binding var isPresented: Bool
    
    @State var text: String
    
    var onComplete: (TextInputResult) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter text", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                    onComplete(.cancelled)
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    isPresented = false
                    onComplete(.saved(text))
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

enum TextInputResult {
    case saved(String)
    case cancelled
}

#Preview {
    TextInputView(isPresented: Binding.constant(true), text: "", onComplete: { result in })
}
