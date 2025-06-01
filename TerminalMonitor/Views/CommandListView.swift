//
//  CommandListView.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandListView: View {
    
    typealias CommandEventHandler = (CommandConfig) -> Void
    
    @Binding var selection: UUID?
    
    @ObservedObject var appViewModel: AppViewModel
    
    @EnvironmentObject private var workspaceConfig: WorkspaceConfig
    
    var commandStartedHandler: CommandEventHandler?
    
    var body: some View {
        ForEach($workspaceConfig.commands, id: \.id) { $command in
            NavigationLink(value: command.id) {
                CommandListViewItem(command: $command)
            }
            .onTapGesture(count: 1) {
                selection = command.id
            }
            .onDrag {
                NSItemProvider(object: command.id.uuidString as NSString)
            }
            .onDrop(of: [.text], delegate: CommandDropDelegate(item: command, items: $workspaceConfig.commands))
            .contextMenu {
                Button("Run", systemImage: "play") {
                    CommandListViewHelper.startCommand(command)
                }
                .labelStyle(.titleAndIcon)
                
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
    }
}

struct CommandListViewItem: View {
    
    @Binding var command: CommandConfig
    
    var body: some View {
        HStack {
            Text(command.name)
                .frame(alignment: .leading)
            
            Spacer()
            
            Button("Run", systemImage: "play") {
                CommandListViewHelper.startCommand(command)
            }
            .labelStyle(.iconOnly)
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
            name: .commandStartingEvent,
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
