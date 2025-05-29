//
//  TerminalView.swift
//  TerminalMonitor
//
//  Created on 2025/5/29.
//

import SwiftUI

struct TerminalView: View {
    
    @State private var terminalLineProducer: TerminalLineProducer = CommandExecutor.shared
    
    @State private var timer: Timer?
    
    @State private var shownLines: [TerminalLine] = []
    
    var body: some View {
        List {
            ForEach(shownLines, id: \.id) { terminalLine in
                HStack {
                    Text(terminalLine.lineFieldDict["system.execution"]?.text ?? "")
                    
                    Spacer()
                    
                    Text(terminalLine.plaintext)
                }
            }
        }
        .toolbar {
            Button("Clear", systemImage: "xmark.bin") {
                shownLines.removeAll()
            }
            .labelStyle(.iconOnly)
        }
        .onAppear {
            terminalLineProducer.startedHandler = {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    Task {
                        let terminalLines = await terminalLineProducer.readTerminalLines()
                        Task { @MainActor in
                            shownLines.append(contentsOf: terminalLines)
                        }
                    }
                }
            }
            terminalLineProducer.completedHandler = {
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

#Preview {
    TerminalView()
}
