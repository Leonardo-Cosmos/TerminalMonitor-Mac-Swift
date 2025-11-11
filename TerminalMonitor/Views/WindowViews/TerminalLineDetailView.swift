//
//  TerminalLineDetailView.swift
//  TerminalMonitor
//
//  Created on 2025/11/10.
//

import SwiftUI

struct TerminalLineDetailView: View {
    
    var window: NSWindow?
    
    var viewModel: TerminalLineDetailViewModel
    
    @State private var selectedFieldIds = Set<TerminalFieldDetailViewModel.ID>()
    
    var body: some View {
        Table(viewModel.fields, selection: $selectedFieldIds) {
            TableColumn("Key") { fieldViewModel in
                Text(fieldViewModel.fieldKey)
            }
            
            TableColumn("Value") { fieldViewModel in
                Text(fieldViewModel.text)
                    .lineLimit(nil)
                    .textSelection(.enabled)
            }
        }
    }
}

class TerminalLineDetailViewModel {
    
    let fields: [TerminalFieldDetailViewModel]
    
    init(fields: [TerminalFieldDetailViewModel]) {
        self.fields = fields
    }
}

class TerminalFieldDetailViewModel: Identifiable {
    
    let fieldKey: String
    
    let text: String
    
    init(fieldKey: String, text: String) {
        self.fieldKey = fieldKey
        self.text = text
    }
}

class TerminalLineDetailWindowController {
    
    static func openWindow(for terminalLine: TerminalLineViewModel) {
        
        let windowContentRect = NSRect(x: 200, y: 200, width: 800, height: 600)
        let window = NSWindow(
            contentRect: windowContentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let terminalFieldDict = terminalLine.lineFieldDict
        let termianlFieldKeys = terminalFieldDict.keys.sorted()
        let terminalFieldDetails = termianlFieldKeys.map { fieldKey in
            let terminalField = terminalFieldDict[fieldKey]!
            return TerminalFieldDetailViewModel(
                fieldKey: fieldKey,
                text: terminalField.text
            )
        }
        let viewModel = TerminalLineDetailViewModel(fields: terminalFieldDetails)
        
        let view = TerminalLineDetailView(window: window, viewModel: viewModel)
        
        let hostingController = NSHostingController(rootView: view)
        window.contentViewController = hostingController
        // Rest window frame after view controller is set
        window.setFrame(windowContentRect, display: true)
        
        let windowController = NSWindowController(window: window)
        windowController.window?.makeKeyAndOrderFront(nil)
        windowController.showWindow(nil)
    }
}

#Preview {
    TerminalLineDetailView(
        viewModel: TerminalLineDetailViewModel(
            fields: [
                TerminalFieldDetailViewModel(fieldKey: "timestamp", text: "00:00"),
                TerminalFieldDetailViewModel(fieldKey: "execution", text: "console"),
                TerminalFieldDetailViewModel(fieldKey: "plaintext", text: "{}"),
            ]
        )
    )
}
