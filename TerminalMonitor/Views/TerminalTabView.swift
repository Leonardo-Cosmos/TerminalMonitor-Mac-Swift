//
//  TerminalTabView.swift
//  TerminalMonitor
//
//  Created on 2025/6/18.
//

import SwiftUI

struct TerminalTabView: View {
    
    private static let selectedTabBackground = Color(nsColor: NSColor.controlBackgroundColor)
    
    private static let unselectedTabBackground = Color(nsColor: NSColor.windowBackgroundColor)
    
    @State private var terminalLineProducer: TerminalLineProducer = CommandExecutor.shared
    
    @State private var terminalLineContainer: TerminalLineContainer = TerminalLineSupervisor.shared
    
    @State private var terminalLineViewer: TerminalLineViewer = TerminalLineSupervisor.shared
    
    @State private var timer: Timer?
    
    @EnvironmentObject private var workspaceConfig: WorkspaceConfig
    
    @State private var selectedTab: UUID?
    
    @State private var hoveringTab: UUID?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ForEach(workspaceConfig.terminals) { terminalConfig in
                    Button(action: {
                        selectedTab = terminalConfig.id
                    }) {
                        Text(terminalConfig.name)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .border(.black, width: 0.5)
                            .background(tabBackground(terminalConfig.id))
                    }
                    .padding(.horizontal, -4)
                    .padding(.vertical, -8)
                    .buttonStyle(PlainButtonStyle())
                    
                    .onHover { hovering in
                        if hovering {
                            hoveringTab = terminalConfig.id
                        } else {
                            if hoveringTab == terminalConfig.id {
                                hoveringTab = nil
                            }
                        }
                    }
                }
            }
            .padding(0)
            
            Divider()
                .padding(0)
            
            Group {
                if let terminalConfig = workspaceConfig.getTerminal(id: selectedTab) {
                    TerminalView(terminalConfig: terminalConfig)
                } else {
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .toolbar {
            Button("Clear", systemImage: "trash") {
                clearTerminal()
            }
            .labelStyle(.iconOnly)
        }
        .onAppear {
            selectedTab = workspaceConfig.terminals.first?.id
            
            terminalLineProducer.startedHandler = {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    Task {
                        let terminalLines = await terminalLineProducer.readTerminalLines()
                        await terminalLineContainer.appendTerminalLines(terminalLines: terminalLines)
                    }
                }
            }
            terminalLineProducer.completedHandler = {
                timer?.invalidate()
                timer = nil
            }
            
            terminalLineContainer.terminalLinesAppendedHandler = { terminalLines in
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .terminalLinesAppendedEvent,
                        object: nil,
                        userInfo: [
                            NotificationUserInfoKey.terminalLines: terminalLines
                        ]
                    )
                }
            }
            terminalLineContainer.terminalLinesRemovedHandler = { terminalLines in
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .terminalLinesRemovedEvent,
                        object: nil,
                        userInfo: [
                            NotificationUserInfoKey.terminalLines: terminalLines
                        ]
                    )
                }
            }
        }
    }
    
    private func tabBackground(_ tabId: UUID) -> Color {
        if selectedTab == tabId {
            return Self.selectedTabBackground
        } else if hoveringTab == tabId {
            return Color.gray.opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    private func appendTerminal() {
        
        let terminalConfig = TerminalConfig(name: "New")
        workspaceConfig.terminals.append(terminalConfig)
    }
    
    private func removeTerminal(terminalId: UUID) {
        
        workspaceConfig.terminals.removeAll(where: { $0.id == terminalId })
    }
    
    private func moveTerminalLeft(terminalId: UUID) {
        
        if let index = workspaceConfig.terminals.firstIndex(where: { $0.id == terminalId}) {
            
            let terminalCount = workspaceConfig.terminals.count
            let terminalConfig = workspaceConfig.terminals.remove(at: index)
            workspaceConfig.terminals.insert(terminalConfig, at: (index - 1 + terminalCount) % terminalCount)
        }
    }
    
    private func moveTerminalRight(terminalId: UUID) {
        
        if let index = workspaceConfig.terminals.firstIndex(where: { $0.id == terminalId}) {
            
            let terminalCount = workspaceConfig.terminals.count
            let terminalConfig = workspaceConfig.terminals.remove(at: index)
            workspaceConfig.terminals.insert(terminalConfig, at: (index + 1) % terminalCount)
        }
    }
    
    private func clearTerminal() {
        terminalLineViewer.removeTerminalLinesUntilLast()
    }
}

#Preview {
    TerminalTabView()
        .environmentObject(previewWorkspaceConfig())
}
