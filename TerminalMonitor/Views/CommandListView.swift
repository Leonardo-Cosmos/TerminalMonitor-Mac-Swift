//
//  CommandListView.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI
import os

struct CommandListView: View {
    
    typealias CommandEventHandler = (CommandConfig) -> Void
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Self.self)
    )
    
    @Binding var selection: UUID?
    
    @ObservedObject var appViewModel: AppViewModel
    
    @EnvironmentObject private var workspaceConfig: WorkspaceConfig
    
    @State private var runningSet: Set<UUID> = Set()
    
    var commandStartedHandler: CommandEventHandler?
    
    var body: some View {
        
        ForEach($workspaceConfig.commands, id: \.id) { $command in
            CommandListViewItem(
                command: $command,
                runningSet: $runningSet
            )
            .onTapGesture(count: 1) {
                selection = command.id
            }
            .onDrag {
                NSItemProvider(object: command.id.uuidString as NSString)
            }
            .onDrop(of: [.text], delegate: CommandDropDelegate(item: command, items: $workspaceConfig.commands))
            .contextMenu {
                SymbolLabelButton(titleKey: "Start", systemImage: "play.fill", symbolColor: .green) {
                    CommandListViewHelper.startCommand(command)
                }
                
                SymbolLabelButton(titleKey: "Stop", systemImage: "stop.fill", symbolColor: .red) {
                    CommandListViewHelper.stopCommand(command)
                }
                .disabled(!runningSet.contains(command.id))
                
                Divider()
                
                Button("Edit", systemImage: "pencil") {
                    CommandListViewHelper.editCommandConfig($command)
                }
                .labelStyle(.titleAndIcon)
                
                Divider()
                
                Button("Add", systemImage: "plus") {
                    CommandListViewHelper.addCommandConfig(workspaceConfig: workspaceConfig)
                }
                .labelStyle(.titleAndIcon)
                
                Button("Remove", systemImage: "minus") {
                    CommandListViewHelper.removeCommandConfig(commandId: command.id, workspaceConfig: workspaceConfig)
                }
                .labelStyle(.titleAndIcon)
            }
            .swipeActions(allowsFullSwipe: false) {
                Button {
                    CommandListViewHelper.editCommandConfig($command)
                } label: {
                    Image(systemName: "pencil")
                }
                
                Button(role: .destructive) {
                    CommandListViewHelper.removeCommandConfig(commandId: command.id, workspaceConfig: workspaceConfig)
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .commandFirstExecutionStartedEvent)) { notification in
            if let commandInfo = notification.userInfo?[NotificationUserInfoKey.command] as? CommandInfo {
                runningSet.insert(commandInfo.id)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.commandFirstExecutionStartedEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .commandLastExecutionExitedEvent)) { notification in
            if let commandInfo = notification.userInfo?[NotificationUserInfoKey.command] as? CommandInfo {
                runningSet.remove(commandInfo.id)
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.commandLastExecutionExitedEvent.rawValue)")
            }
        }
    }
}

struct CommandListViewItem: View {
    
    @Binding var command: CommandConfig
    
    @Binding var runningSet: Set<UUID>
    
    @State var isHoveringStart = false
    
    @State var isHoveringStop = false
    
    var body: some View {
        HStack {
            Text(command.name)
                .frame(alignment: .leading)
            
            Spacer()
            
            if runningSet.contains(command.id) {
                SymbolButton(systemImage: "stop.fill", symbolColor: .red) {
                    CommandListViewHelper.stopCommand(command)
                }
                .help("Stop")
            }
            
            SymbolButton(systemImage: "play.fill", symbolColor: .green) {
                CommandListViewHelper.startCommand(command)
            }
            .help("Start")
        }
    }
}


struct CommandListViewHelper {
    
    static func addCommandConfig(workspaceConfig: WorkspaceConfig) {
        var commandConfig = CommandConfig(name: "")
        CommandDetailWindowController.openWindow(for: Binding(
            get: { commandConfig },
            set: { commandConfig = $0 }
        )) {
            workspaceConfig.append(commandConfig)
        }
    }
    
    static func editCommandConfig(_ commandConfig: Binding<CommandConfig>) {
        
        CommandDetailWindowController.openWindow(for: commandConfig)
    }
    
    static func removeCommandConfig(commandId: UUID, workspaceConfig: WorkspaceConfig) {
        
        workspaceConfig.delete(id: commandId)
    }
    
    static func startCommand(_ commandConfig: CommandConfig) {
        
        NotificationCenter.default.post(
            name: .commandToStartEvent,
            object: nil,
            userInfo: [NotificationUserInfoKey.command: commandConfig]
        )
    }
    
    static func stopCommand(_ commandConfig: CommandConfig) {
        
        NotificationCenter.default.post(
            name: .commandToStopEvent,
            object: nil,
            userInfo: [NotificationUserInfoKey.command: commandConfig]
        )
    }
}

fileprivate class CommandDropDelegate: ListItemDropDelegate<CommandConfig, UUID> {
    
    convenience init(item: CommandConfig, items: Binding<[CommandConfig]>) {
        self.init(id: \.id, item: item, items: items) { provider in
            UUID(uuidString: provider as? String ?? "")
        }
    }
}

#Preview {
    CommandListView(
        selection: Binding.constant(UUID()),
        appViewModel: AppViewModel()
    )
    .environmentObject(previewWorkspaceConfig())
}

func previewWorkspaceConfig() -> WorkspaceConfig {
    let workspaceConfig = WorkspaceConfig()
    workspaceConfig.commands = [
        CommandConfig(name: "Console"),
        CommandConfig(name: "Application"),
        CommandConfig(name: "Tool"),
    ]
    return workspaceConfig
}
