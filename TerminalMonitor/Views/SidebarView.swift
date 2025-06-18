//
//  SidebarView.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct SidebarView: View {
    
    @ObservedObject var appViewModel: AppViewModel
    
    @EnvironmentObject private var workspaceConfig: WorkspaceConfig
    
    @State private var selection: UUID?
    
    @State private var isCommandListExpanded = true
    
    @State private var isExecutionListExpanded = true
    
    var body: some View {
        List(selection: $selection) {
            Section("Command") {
                CommandListView(selection: $selection, appViewModel: appViewModel)
            }
            
            Section("Execution") {
                ExecutionListView(selection: $selection)
            }
        }
        .toolbar {
            Button("Add Command", systemImage: "plus") {
                CommandListViewHelper.addCommandConfig(workspaceConfig: workspaceConfig)
            }
        }
        .disabled(!appViewModel.workspaceLoaded)
    }
}

#Preview {
    SidebarView(appViewModel: AppViewModel())
        .environmentObject(WorkspaceConfig())
}
