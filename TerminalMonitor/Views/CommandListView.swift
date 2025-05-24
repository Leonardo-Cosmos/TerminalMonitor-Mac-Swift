//
//  CommandListView.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandListView: View {
    
    @ObservedObject var appViewModel: AppViewModel
    
    @EnvironmentObject private var workspaceConfig: WorkspaceConfig
    
    @State private var commands: [CommandConfig] = [
        CommandConfig(name: "1")
    ]
    
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
        CommandConfig(name: "a"),
        CommandConfig(name: "b"),
        CommandConfig(name: "c"),
    ]
    return workspaceConfig
}
