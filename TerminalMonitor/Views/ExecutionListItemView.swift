//
//  ExecutionListItemView.swift
//  TerminalMonitor
//
//  Created by on 2025/11/29.
//

import SwiftUI

struct ExecutionListItemView: View {
    
    @State var execution: ExecutionInfo
    
    @State var terminated = false
    
    @Binding var changeSet: Set<UUID>
    
    var body: some View {
        HStack {
            Text(execution.name)
                .frame(alignment: .leading)
            
            Spacer()
            
            SymbolButton(systemImage: "arrow.circlepath", symbolColor: .blue) {
                terminated = true
                ExecutionListViewHelper.restartExecution(executionId: execution.id)
            }
            .disabled(terminated)
            .help("Restart")
            
            SymbolButton(systemImage: "stop.fill", symbolColor: .red) {
                terminated = true
                ExecutionListViewHelper.stopExecution(executionId: execution.id)
            }
            .disabled(terminated)
            .help("Stop")
        }
        .offset(y: changeSet.contains(execution.id) ? -10 : 0)
        .opacity(changeSet.contains(execution.id) ? 0.1 : 1.0)
    }
}

#Preview {
    ExecutionListItemView(
        execution: previewExecutionInfo()[0],
        changeSet: Binding.constant([])
    )
}
