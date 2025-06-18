//
//  ContentView.swift
//  TerminalMonitor
//
//  Created on 2025/5/8.
//

import SwiftUI
import SwiftData
import os

struct ContentView: View {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Self.self)
    )
    
    @State private var executor: Executor = CommandExecutor.shared
    
    @ObservedObject var appViewModel: AppViewModel
    
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            SidebarView(appViewModel: appViewModel)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            TerminalView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .commandToStartEvent)) { notification in
            if let commandConfig = notification.userInfo?[NotificationUserInfoKey.command] as? CommandConfig {
                executor.execute(commandConfig: commandConfig)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.commandToStartEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .commandToStopEvent)) { notification in
            if let commandConfig = notification.userInfo?[NotificationUserInfoKey.command] as? CommandConfig {
                executor.terminateAll(commandId: commandConfig.id)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.commandToStopEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .executionToStopEvent)) { notification in
            if let executionId = notification.userInfo?[NotificationUserInfoKey.id] as? UUID {
                executor.terminate(executionId: executionId)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.executionToStopEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .executionToRestartEvent)) { notification in
            if let executionId = notification.userInfo?[NotificationUserInfoKey.id] as? UUID {
                executor.restart(executionId: executionId)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.executionToRestartEvent.rawValue)")
            }
        }
        .onAppear {
            executor.executionStartedHandler = { executionInfo, _ in
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .executionStartedEvent,
                        object: nil,
                        userInfo: [NotificationUserInfoKey.execution: executionInfo]
                    )
                }
            }
            executor.executionExitedHandler = { executionInfo, error in
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .executionExitedEvent,
                        object: nil,
                        userInfo: [
                            NotificationUserInfoKey.execution: executionInfo,
                            NotificationUserInfoKey.error: error as Any
                        ]
                    )
                }
            }
            executor.commandFirstExecutionStartedHandler = { commandInfo in
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .commandFirstExecutionStartedEvent,
                        object: nil,
                        userInfo: [
                            NotificationUserInfoKey.command: commandInfo
                        ]
                    )
                }
            }
            executor.commandLastExecutionExitedHandler = { commandInfo in
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .commandLastExecutionExitedEvent,
                        object: nil,
                        userInfo: [
                            NotificationUserInfoKey.command: commandInfo
                        ]
                    )
                }
            }
        }
    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView(appViewModel: AppViewModel())
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(WorkspaceConfig())
}
