//
//  ExecutionListView.swift
//  TerminalMonitor
//
//  Created on 2025/5/28.
//

import SwiftUI
import os

struct ExecutionListView: View {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Self.self)
    )
    
    @Binding var selection: UUID?
    
    @State var executions: [ExecutionInfo] = []
    
    @State private var showError = false
    
    @State private var errorMessage = ""
    
    @State private var changeSet: Set<UUID> = Set()
    
    var body: some View {
        ForEach(executions, id: \.id) { execution in
            NavigationLink(value: execution.id) {
                ExecutionListViewItem(execution: execution, changeSet: $changeSet)
            }
            .onTapGesture(count: 1) {
                selection = execution.id
            }
            .onDrag {
                NSItemProvider(object: execution.id.uuidString as NSString)
            }
            .onDrop(of: [.text], delegate: ExecutionDropDelegate(item: execution, items: $executions))
            .contextMenu {
                Button("Stop", systemImage: "stop") {
                    ExecutionListViewHelper.stopExecution(executionId: execution.id)
                }
                .labelStyle(.titleAndIcon)
                
                Button("Restart", systemImage: "arrow.circlepath") {
                    ExecutionListViewHelper.restartExecution(executionId: execution.id)
                }
                .labelStyle(.titleAndIcon)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .executionStartedEvent)) { notification in
            if let execution = notification.userInfo?[NotificationUserInfoKey.execution] as? ExecutionInfo {
                changeSet.insert(execution.id)
                executions.append(execution)
                
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        _ = changeSet.remove(execution.id)
                    }
                }
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.executionStartedEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .executionExitedEvent)) { notification in
            if let execution = notification.userInfo?[NotificationUserInfoKey.execution] as? ExecutionInfo {
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    _ = changeSet.insert(execution.id)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    executions.removeAll(where: { $0.id == execution.id })
                    changeSet.remove(execution.id)
                }
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.executionExitedEvent.rawValue)")
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

struct ExecutionListViewItem: View {
    
    @State var execution: ExecutionInfo
    
    @Binding var changeSet: Set<UUID>
    
    var body: some View {
        HStack {
            Text(execution.name)
                .frame(alignment: .leading)
            
            Spacer()
            
            Button("Stop", systemImage: "stop") {
                ExecutionListViewHelper.stopExecution(executionId: execution.id)
            }
            .labelStyle(.iconOnly)
            
            Button("Restart", systemImage: "arrow.circlepath") {
                ExecutionListViewHelper.restartExecution(executionId: execution.id)
            }
            .labelStyle(.iconOnly)
        }
        .offset(y: changeSet.contains(execution.id) ? -10 : 0)
        .opacity(changeSet.contains(execution.id) ? 0.1 : 1.0)
    }
}

struct ExecutionListViewHelper {
    
    static func stopExecution(executionId: UUID) {
        
        NotificationCenter.default.post(
            name: .executionToStopEvent,
            object: nil,
            userInfo: [NotificationUserInfoKey.id: executionId]
        )
    }
    
    static func restartExecution(executionId: UUID) {
        
        NotificationCenter.default.post(
            name: .executionToRestartEvent,
            object: nil,
            userInfo: [NotificationUserInfoKey.id: executionId]
        )
    }
}

fileprivate class ExecutionDropDelegate: ListItemDropDelegate<ExecutionInfo, UUID> {
    
    convenience init(item: ExecutionInfo, items: Binding<[ExecutionInfo]>) {
        self.init(id: \.id, item: item, items: items) { provider in
            UUID(uuidString: provider as? String ?? "")
        }
    }
}

#Preview {
    ExecutionListView(
        selection: Binding.constant(UUID()),
        executions: [
            ExecutionInfo(id: UUID(), name: "Console", status: .started),
            ExecutionInfo(id: UUID(), name: "Application", status: .started),
            ExecutionInfo(id: UUID(), name: "Tool", status: .started),
        ]
    )
}
