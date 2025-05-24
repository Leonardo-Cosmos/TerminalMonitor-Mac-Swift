//
//  CommandConfigDetailWindow.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandDetailView: View {
    
    var window: NSWindow?
    
    @Binding var commandConfig: CommandConfig
    
    var onSave: (() -> Void)?
    
    var body: some View {
        VStack {
            TextField("Name", text: $commandConfig.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save") {
                onSave?()
                window?.close()
            }
            .padding()
        }
    }
}

class CommandDetailWindowController {
    
//    static func openDetail(for item: CommandConfig) {
//        let commandDetailView = CommandDetailView()
//        let window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
//            styleMask: [.titled, .resizable],
//            backing: .buffered,
//            defer: false
//        )
//        window.contentView = NSHostingView(rootView: commandDetailView)
//        window.makeKeyAndOrderFront(nil)
//    }
    
    static func openWindow(for commandConfig: Binding<CommandConfig>, onSave: (() -> Void)? = nil) {
        
        let windowContentRect = NSRect(x: 200, y: 200, width: 400, height: 300)
        let window = NSWindow(
            contentRect: windowContentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        var viewModel = CommandConfig(
            name: commandConfig.name.wrappedValue,
            startFile: commandConfig.startFile.wrappedValue,
        )
        
        let view = CommandDetailView(window: window, commandConfig: Binding(
            get: { viewModel },
            set: { viewModel = $0 }
        ), onSave: {
            // Update binding value of list view only when save button is clicked
            commandConfig.name.wrappedValue = viewModel.name
            commandConfig.startFile.wrappedValue = viewModel.startFile
            
            onSave?()
        })
        let hostingController = NSHostingController(rootView: view)
        window.contentViewController = hostingController
        // Rest window frame after view controller is set
        window.setFrame(windowContentRect, display: true)
        
        let windowController = NSWindowController(window: window)
        windowController.window?.makeKeyAndOrderFront(nil)
        windowController.showWindow(nil)
    }
}
//
//class WindowController: NSWindowController {
//    convenience init(view: AnyView) {
//        let hostingController = NSHostingController(rootView: view)
//        let window = NSWindow(
//                contentViewController: hostingController
//        )
//        window.styleMask = [.titled, .closable, .resizable]
//        window.setFrame(NSRect(x: 200, y: 200, width: 400, height: 300), display: true)
//
//        self.init(window: window)
//        self.window?.makeKeyAndOrderFront(nil)
//    }
//}

#Preview {
    CommandDetailView(window: nil,
                      commandConfig: Binding.constant(CommandConfig(name: "Command")),
                      onSave: {})
}
