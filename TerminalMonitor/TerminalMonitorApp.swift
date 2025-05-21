//
//  TerminalMonitorApp.swift
//  TerminalMonitor
//
//  Created on 2025/5/8.
//

import SwiftUI
import SwiftData
import os

@main
struct TerminalMonitorApp: App {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Self.self)
    )
    
    @AppStorage("workspace")
    private var openedWorkspace: String?
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open Workspace...") {
                    openWorkspace()
                }
                .keyboardShortcut("O", modifiers: [.command])
                
                Button("Close Workspace") {
                    
                }
                .keyboardShortcut("W", modifiers: [.command])
            }
        }
    }
    
    func loadWorkspace() {
        guard let openedWorkspace = openedWorkspace else {
            return
        }
        
        if let bookmarkData = Data(base64Encoded: openedWorkspace) {
            var isStale = false
            do {
                let fileUrl = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                _ = fileUrl.startAccessingSecurityScopedResource()
            } catch let error as NSError {
                
            }
        }
    }
    
    func openWorkspace() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                print("Selected file: \(url.path)")
            }
        }
    }
}
