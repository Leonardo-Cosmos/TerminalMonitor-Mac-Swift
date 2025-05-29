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
    
    @ObservedObject var appViewModel: AppViewModel
    
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            SidebarView(appViewModel: appViewModel)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            Text("Select an item")
        }
        .onReceive(NotificationCenter.default.publisher(for: .commandStartingEvent)) { notification in
            if let commandConfig = notification.userInfo?[NotificationUserInfoKey.command] as? CommandConfig {
                CommandExecutor.shared.execute(commandConfig: commandConfig)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.commandStartingEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .executionTerminatingEvent)) { notification in
            if let executionId = notification.userInfo?[NotificationUserInfoKey.id] as? UUID {
                CommandExecutor.shared.terminate(executionId: executionId)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.executionTerminatingEvent.rawValue)")
            }
        }
        .onAppear {
            CommandExecutor.shared.executionStartedHandler = { executionInfo, _ in
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .executionStartedEvent,
                        object: nil,
                        userInfo: [NotificationUserInfoKey.execution: executionInfo]
                    )
                }
            }
            CommandExecutor.shared.executionExitedHandler = { executionInfo, error in
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
}
