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
    private var workspaceBookmark: String?
    
    @StateObject private var viewModel = AppViewModel()
    
    private var workspaceUrl: URL?
    
    private var workspaceConfig = WorkspaceConfig()
    
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
            CommandGroup(replacing: .newItem) {
                Button("New Workspace...") {
                    createWorkspace()
                }
                .keyboardShortcut("N", modifiers: [.command])
                
                Button("Open Workspace...") {
                    openWorkspace()
                }
                .keyboardShortcut("O", modifiers: [.command])
                
                Button("Save Workspace") {
                    saveWorkspace()
                }
                .keyboardShortcut("S", modifiers: [.command])
                
                Button("Close Workspace") {
                    closeWorkspace()
                }
                .keyboardShortcut("W", modifiers: [.command])
            }
        }
    }
    
    private mutating func loadWorkspace() {
        guard let workspaceBookmark = workspaceBookmark else {
            return
        }
        
        if let bookmarkData = Data(base64Encoded: workspaceBookmark) {
            var isStale = false
            
            var url: URL
            do {
                url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                _ = url.startAccessingSecurityScopedResource()
                
                workspaceUrl = url
                
            } catch let error as NSError {
                Self.logger.error("Cannot restore workspace URL bookmark. \(error)")
                viewModel.workspaceError = "Cannot restore workspace URL bookmark"
                
                return
            }
            
            do {
                try readWorkspaceFile(url: url)
                
                viewModel.workspaceLoaded = true
                
            } catch let error as NSError {
                Self.logger.error("Cannot read existing workspace setting. \(error)")
                viewModel.workspaceError = "Cannot read existing workspace setting"
                
                viewModel.workspaceLoaded = false
            }
        }
    }
    
    private func createWorkspace() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        
        if panel.runModal() == .OK, let url = panel.url {
            Self.logger.debug("Created file: \(url.path(percentEncoded: false))")
            
            do {
                try writeWorkspaceFile(url: url)
                
                viewModel.workspaceLoaded = true
                
            } catch let error as NSError {
                Self.logger.error("Cannot create workspace setting. \(error)")
                viewModel.workspaceError = "Cannot create workspace setting"
                
                return
            }
            
            do {
                workspaceBookmark = try url.bookmarkData().base64EncodedString()
            } catch let error as NSError {
                Self.logger.error("Cannot save workspace URL bookmark. \(error)")
                viewModel.workspaceError = "Cannot save workspace URL bookmark"
            }
        }
    }
    
    private func openWorkspace() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            Self.logger.debug("Opened file: \(url.path(percentEncoded: false))")
            
            do {
                workspaceBookmark = try url.bookmarkData().base64EncodedString()
            } catch let error as NSError {
                Self.logger.error("Cannot save workspace URL bookmark. \(error)")
                viewModel.workspaceError = "Cannot save workspace URL bookmark"
            }
            
            do {
                try readWorkspaceFile(url: url)
                
                viewModel.workspaceLoaded = true
                
            } catch let error as NSError {
                Self.logger.error("Cannot open workspace setting. \(error)")
                viewModel.workspaceError = "Cannot open workspace setting"
            }
        }
    }
    
    private func saveWorkspace() {
        
        guard let workspaceUrl = workspaceUrl else {
            return
        }
        
        do {
            try writeWorkspaceFile(url: workspaceUrl)
            
        } catch let error as NSError {
            Self.logger.error("Cannot save workspace setting. \(error)")
            viewModel.workspaceError = "Cannot save workspace setting"
        }
    }
    
    private func closeWorkspace() {
        
        // TODO
        // Terminate all running commands.
        
        guard let workspaceUrl = workspaceUrl else {
            return
        }
        
        do {
            try writeWorkspaceFile(url: workspaceUrl)
            
            viewModel.workspaceLoaded = false
            
        } catch let error as NSError {
            Self.logger.error("Cannot save workspace setting. \(error)")
            viewModel.workspaceError = "Cannot save workspace setting"
        }
    }
    
    private func readWorkspaceFile(url: URL) throws {
        
        let workspaceSetting = try SettingSerializer.deserialize(settingFilePath: url.path(percentEncoded: false))
        
        let commands = workspaceSetting.commands?
            .map { command in CommandConfigSettingHelper.load(command)! }
        workspaceConfig.commands = commands ?? []
    }
    
    private func writeWorkspaceFile(url: URL) throws {
        
        let commandSettings = workspaceConfig.commands
            .map { command in CommandConfigSettingHelper.save(command)! }
        
        let workspaceSetting = WorkspaceSetting(commands: commandSettings)
        
        try SettingSerializer.serialize(workspaceSetting: workspaceSetting, settingFilePath: url.path(percentEncoded: false))
    }
}

class AppViewModel: ObservableObject {
    
    @Published var workspaceLoaded = false
    
    @Published var workspaceError: String?
}
