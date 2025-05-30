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
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("workspace")
    private var workspaceBookmark: String?
    
    @StateObject private var viewModel = AppViewModel()
    
    @State private var workspaceUrl: URL?
    
    @State private var workspaceConfig = WorkspaceConfig()
    
    @State private var executor: Executor = CommandExecutor.shared
    
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
            ContentView(appViewModel: viewModel)
                .onAppear(perform: loadWorkspace)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Workspace...") {
                    createWorkspace()
                }
                .keyboardShortcut("N", modifiers: [.command])
                .disabled(viewModel.workspaceLoaded)
                
                Button("Open Workspace...") {
                    openWorkspace()
                }
                .keyboardShortcut("O", modifiers: [.command])
                .disabled(viewModel.workspaceLoaded)
                
                Button("Save Workspace") {
                    saveWorkspace()
                }
                .keyboardShortcut("S", modifiers: [.command])
                .disabled(!viewModel.workspaceLoaded)
                
                Button("Close Workspace") {
                    closeWorkspace()
                }
                .keyboardShortcut("W", modifiers: [.command])
                .disabled(!viewModel.workspaceLoaded)
            }
        }
        .environmentObject(workspaceConfig)
    }
    
    private func loadWorkspace() {
        Self.logger.debug("Loading workspace")
        
        appDelegate.applicationTerminationHandler = {
            
            executor.shutdown()
            
            if viewModel.workspaceLoaded {
                saveWorkspace()
            }
        }
        
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
                
            } catch {
                Self.logger.error("Cannot restore workspace URL bookmark. \(error)")
                viewModel.workspaceError = "Cannot restore workspace URL bookmark"
                
                return
            }
            
            do {
                try readWorkspaceFile(url: url)
                
                viewModel.workspaceLoaded = true
                
                Self.logger.debug("Loaded workspace")
                
            } catch {
                Self.logger.error("Cannot read existing workspace setting. \(error)")
                viewModel.workspaceError = "Cannot read existing workspace setting"
                
                viewModel.workspaceLoaded = false
            }
        }
    }
    
    private func createWorkspace() {
        Self.logger.debug("Create workspace")
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        
        if panel.runModal() == .OK, let url = panel.url {
            Self.logger.debug("Created file: \(url.path(percentEncoded: false))")
            
            workspaceUrl = url
            
            do {
                try writeWorkspaceFile(url: url)
                
                viewModel.workspaceLoaded = true
                
            } catch {
                Self.logger.error("Cannot create workspace setting. \(error)")
                viewModel.workspaceError = "Cannot create workspace setting"
                
                return
            }
            
            
            do {
                workspaceBookmark = try url.bookmarkData().base64EncodedString()
                
                Self.logger.debug("Created workspace")
                
            } catch {
                Self.logger.error("Cannot save workspace URL bookmark. \(error)")
                viewModel.workspaceError = "Cannot save workspace URL bookmark"
            }
        }
    }
    
    private func openWorkspace() {
        Self.logger.debug("Opening workspace")
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            Self.logger.debug("Opened file: \(url.path(percentEncoded: false))")
            
            
            if viewModel.workspaceLoaded {
                closeWorkspace()
            }
            
            workspaceUrl = url
            
            do {
                workspaceBookmark = try url.bookmarkData().base64EncodedString()
            } catch {
                Self.logger.error("Cannot save workspace URL bookmark. \(error)")
                viewModel.workspaceError = "Cannot save workspace URL bookmark"
            }
            
            do {
                try readWorkspaceFile(url: url)
                
                workspaceUrl = url
                viewModel.workspaceLoaded = true
                
                Self.logger.debug("Opened workspace")
                
            } catch {
                Self.logger.error("Cannot open workspace setting. \(error)")
                viewModel.workspaceError = "Cannot open workspace setting"
            }
        }
    }
    
    private func saveWorkspace() {
        Self.logger.debug("Saving workspace")
        
        guard let workspaceUrl = workspaceUrl else {
            return
        }
        
        do {
            try writeWorkspaceFile(url: workspaceUrl)
            
            Self.logger.debug("Saved workspace")
            
        } catch {
            Self.logger.error("Cannot save workspace setting. \(error)")
            viewModel.workspaceError = "Cannot save workspace setting"
        }
    }
    
    private func closeWorkspace() {
        Self.logger.debug("Closing workspace")
        
        executor.shutdown()
        
        guard let workspaceUrl = workspaceUrl else {
            return
        }
        
        do {
            try writeWorkspaceFile(url: workspaceUrl)
            
            clearWorkspace()
            viewModel.workspaceLoaded = false
            
            self.workspaceUrl = nil
            workspaceBookmark = nil
            
            Self.logger.debug("Closed workspace")
            
        } catch {
            Self.logger.error("Cannot save workspace setting. \(error)")
            viewModel.workspaceError = "Cannot save workspace setting"
        }
    }
    
    private func clearWorkspace() {
        
        workspaceConfig.commands = []
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

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppDelegate.self)
    )
    
    var applicationTerminationHandler: (() -> Void)?
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Self.logger.debug("Application will terminate")
        applicationTerminationHandler?()
    }
}
