//
//  CommandConfigDetailWindow.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandDetailView: View {
    
    var window: NSWindow?
    
    @ObservedObject var viewModel: CommandDetailViewModel
    
    var onSave: (() -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Text("Name(*)")
                    .frame(width: 80)
                TextField("Unique name of the command", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            HStack {
                Text("Command(*)")
                    .frame(maxWidth: 80)
                TextField("Full path of the executable file", text: $viewModel.executableFile)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            HStack {
                Text("Arguments")
                    .frame(maxWidth: 80)
                TextField("Arguments of the command, separating by white space", text: $viewModel.arguments)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            HStack {
                Text("Directory")
                    .frame(maxWidth: 80)
                TextField("The working directory where to run the command", text: $viewModel.currentDirectory)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Browse", systemImage: "folder") {
                    if let path = selectDirectory(dirPath: viewModel.currentDirectory) {
                        viewModel.currentDirectory = path
                        viewModel.objectWillChange.send()
                    }
                }
                .labelStyle(.iconOnly)
            }
            .padding()
            
            Button("Save") {
                onSave?()
                window?.close()
            }
            .padding()
        }
        .frame(minWidth: 400)
    }
    
    private func selectDirectory(dirPath: String) -> String? {
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        if !dirPath.isEmpty {
            panel.directoryURL = URL(filePath: dirPath, directoryHint: .isDirectory)
        }
        
        if panel.runModal() == .OK, let url = panel.url {
            return url.path(percentEncoded: false)
        } else {
            return nil
        }
    }
}

class CommandDetailViewModel: ObservableObject {
    
    @Published var name: String
    
    @Published var executableFile: String
    
    @Published var arguments: String
    
    @Published var currentDirectory: String
    
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
        
        let windowContentRect = NSRect(x: 200, y: 200, width: 800, height: 200)
        let window = NSWindow(
            contentRect: windowContentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let viewModel = CommandDetailViewModel(
            name: commandConfig.name.wrappedValue,
            executableFile: commandConfig.executableFile.wrappedValue ?? "",
            arguments: commandConfig.arguments.wrappedValue ?? "",
            currentDirectory: commandConfig.currentDirectory.wrappedValue ?? ""
        )
        
        let view = CommandDetailView(window: window, viewModel: viewModel, onSave: {
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
                      viewModel: CommandDetailViewModel(name: "Command"),
                      onSave: {})
}
