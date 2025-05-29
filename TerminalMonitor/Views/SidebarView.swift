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
    
    @State private var isCommandListExpanded = true
    
    @State private var isExecutionListExpanded = true
    
    var body: some View {
        List {
            
                DisclosureGroup("Command", isExpanded: $isCommandListExpanded) {
                    CommandListView(appViewModel: appViewModel)
                }
            
//            Rectangle()
//                .frame(height: 4)
//                .gesture(
//                    DragGesture()
//                        .onChanged { gesture in
//                            commandListHeight = max(50, commandListHeight + gesture.translation.height)
//                        }
//                )
            
            DisclosureGroup("Exectuion", isExpanded: $isExecutionListExpanded) {
                ExecutionListView()
            }
        }
        .listStyle(SidebarListStyle())
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
    SidebarView(appViewModel: AppViewModel())
        .environmentObject(WorkspaceConfig())
}
