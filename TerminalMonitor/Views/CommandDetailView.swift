//
//  CommandConfigDetailWindow.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandDetailView: View {
    
    var window: NSWindow?
    
    @Binding var viewModel: CommandDetailViewModel
    
    var onSave: (() -> Void)?
    
    var body: some View {
        VStack {
            TextField("Name", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Command", text: $viewModel.executableFile)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Arguments", text: $viewModel.arguments)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Working Directory", text: $viewModel.currentDirectory)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Save") {
                onSave?()
                window?.close()
            }
            .padding()
        }
    }
}

class CommandDetailViewModel: ObservableObject {
    
    var name: String
    
    var executableFile: String
    
    var arguments: String
    
    var currentDirectory: String
    
    init(name: String, executableFile: String, arguments: String, currentDirectory: String) {
        self.name = name
        self.executableFile = executableFile
        self.arguments = arguments
        self.currentDirectory = currentDirectory
    }
    
    convenience init(name: String) {
        self.init(
            name: name,
            executableFile: "",
            arguments: "",
            currentDirectory: ""
        )
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
        
        var viewModel = CommandDetailViewModel(
            name: commandConfig.name.wrappedValue,
            executableFile: commandConfig.executableFile.wrappedValue ?? "",
            arguments: commandConfig.arguments.wrappedValue ?? "",
            currentDirectory: commandConfig.currentDirectory.wrappedValue ?? ""
        )
        
        let view = CommandDetailView(window: window, viewModel: Binding(
            get: { viewModel },
            set: { viewModel = $0 }
        ), onSave: {
            // Update binding value of list view only when save button is clicked
            commandConfig.name.wrappedValue = viewModel.name
            commandConfig.executableFile.wrappedValue = viewModel.executableFile.isEmpty ? nil : viewModel.executableFile
            commandConfig.arguments.wrappedValue = viewModel.arguments.isEmpty ? nil : viewModel.arguments
            commandConfig.currentDirectory.wrappedValue = viewModel.currentDirectory.isEmpty ? nil : viewModel.currentDirectory
            
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
                      viewModel: Binding.constant(CommandDetailViewModel(name: "Command")),
                      onSave: {})
}
