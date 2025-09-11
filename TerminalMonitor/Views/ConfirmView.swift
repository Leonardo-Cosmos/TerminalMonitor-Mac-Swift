//
//  ConfirmView.swift
//  TerminalMonitor
//
//  Created on 2025/9/11.
//

import SwiftUI

struct ConfirmView: View {
    
    @Binding var isPresented: Bool
    
    @State var message: String
    
    var onSubmit: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.headline)
            
            HStack {
                Button("No") {
                    isPresented = false
                    onSubmit(false)
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Yes") {
                    isPresented = false
                    onSubmit(true)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    ConfirmView(isPresented: Binding.constant(true), message: "Confirm", onSubmit: { result in })
}
