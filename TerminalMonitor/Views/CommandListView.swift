//
//  CommandListView.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandListView: View {
    
    typealias CommandEventHandler = (CommandConfig) -> Void
    
    @ObservedObject var appViewModel: AppViewModel
    
    @EnvironmentObject private var workspaceConfig: WorkspaceConfig
    
    var commandStartedHandler: CommandEventHandler?
    
    var body: some View {
        List($workspaceConfig.commands, id: \.id) { $command in
            HStack {
                Text(command.name)
                    .frame(alignment: .leading)
                
                Spacer()
                
                Button("Edit", systemImage: "pencil") {
                    CommandDetailWindowController.openWindow(for: $command)
                }
                .labelStyle(.iconOnly)
                
                Button("Remove", systemImage: "minus") {
                    workspaceConfig.delete(id: command.id)
                }
                .labelStyle(.iconOnly)
                
                Button("Start", systemImage: "play") {
                    NotificationCenter.default.post(
                        name: .commandStartingEvent,
                        object: nil,
                        userInfo: [NotificationUserInfoKey.command: command]
                    )
                }
                .labelStyle(.iconOnly)
            }
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                var commandConfig = CommandConfig(name: "")
                CommandDetailWindowController.openWindow(for: Binding(
                    get: { commandConfig },
                    set: { commandConfig = $0 }
                )) {
                    workspaceConfig.append(commandConfig)
                }
            }
        }
        .disabled(!appViewModel.workspaceLoaded)
    }
}

#Preview {
    CommandListView(appViewModel: AppViewModel())
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
