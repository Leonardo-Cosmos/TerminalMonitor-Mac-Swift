//
//  SidebarView.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct SidebarView: View {
    
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack {
            Section("Command") {
                CommandListView(appViewModel: appViewModel)
            }
            
            Section("Exectuion") {
                ExecutionListView()
            }
        }
    }
}

#Preview {
    SidebarView(appViewModel: AppViewModel())
}
