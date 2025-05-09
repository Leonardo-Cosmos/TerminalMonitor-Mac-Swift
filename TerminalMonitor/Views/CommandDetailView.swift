//
//  CommandConfigDetailWindow.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandDetailView: View {
    
    var window: NSWindow?
    
    @State private var name = ""
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save") {
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
    
    static func openWindow(for item: CommandConfig) {
        
        let windowContentRect = NSRect(x: 200, y: 200, width: 400, height: 300)
        let window = NSWindow(
            contentRect: windowContentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let view = CommandDetailView(window: window)
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
    CommandDetailView()
}
