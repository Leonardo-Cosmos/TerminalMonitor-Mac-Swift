//
//  ExecutionListView.swift
//  TerminalMonitor
//
//  Created on 2025/5/28.
//

import SwiftUI

struct ExecutionListView: View {
    
    @State var executions: [ExecutionInfo] = []
    
    @State private var showError = false
    
    @State private var errorMessage = ""
    
    var body: some View {
        ForEach(executions, id: \.id) { execution in
            HStack {
                Text(execution.name)
                    .frame(alignment: .leading)
                
                Spacer()
                
                Button("Terminate", systemImage: "stop") {
                    NotificationCenter.default.post(
                        name: .executionTerminatingEvent,
                        object: nil,
                        userInfo: [NotificationUserInfoKey.id: execution.id]
                    )
                }
                .labelStyle(.iconOnly)
            }
            .onDrag {
                NSItemProvider(object: execution.id.uuidString as NSString)
            }
            .onDrop(of: [.text], delegate: ExecutionDropDelegate(item: execution, items: $executions))
        }
        .onReceive(NotificationCenter.default.publisher(for: .executionStartedEvent)) { notification in
            if let execution = notification.userInfo?[NotificationUserInfoKey.execution] as? ExecutionInfo {
                executions.append(execution)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .executionExitedEvent)) { notification in
            if let execution = notification.userInfo?[NotificationUserInfoKey.execution] as? ExecutionInfo {
                executions.removeAll(where: { $0.id == execution.id })
            }
            
            if let error = notification.userInfo?[NotificationUserInfoKey.error] as? Error {
                errorMessage = "\(error)"
                showError = true
            }
        }
        .popover(isPresented: $showError) {
            Text(errorMessage)
                .padding()
        }
    }
}

fileprivate class ExecutionDropDelegate: ListItemDropDelegate<ExecutionInfo, UUID> {
    
    convenience init(item: ExecutionInfo, items: Binding<[ExecutionInfo]>) {
        self.init(id: \.id, item: item, items: items)
    }
    
    override func id(from provider: (any NSItemProviderReading)?) -> UUID? {
        UUID(uuidString: provider as? String ?? "")
    }
}

#Preview {
    ExecutionListView(executions: [
        ExecutionInfo(id: UUID(), name: "Console", status: .started),
        ExecutionInfo(id: UUID(), name: "Application", status: .started),
        ExecutionInfo(id: UUID(), name: "Tool", status: .started),
    ])
}
