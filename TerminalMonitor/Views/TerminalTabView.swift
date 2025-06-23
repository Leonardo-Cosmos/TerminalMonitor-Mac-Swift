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
    
    @State private var terminalSupervisor: TerminalSupervisor = TerminalLineArraySupervisor.shared
    
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
        .onAppear {
            selectedTab = workspaceConfig.terminals[0].id
            
            terminalLineProducer.startedHandler = {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    Task {
                        let terminalLines = await terminalLineProducer.readTerminalLines()
                        await terminalSupervisor.appendTerminalLines(terminalLines: terminalLines)
                    }
                }
            }
            terminalLineProducer.completedHandler = {
                timer?.invalidate()
                timer = nil
            }
            
            terminalSupervisor.terminalLinesAppendedHandler = { terminalLines in
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
            terminalSupervisor.terminalLinesRemovedHandler = { terminalLines in
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
}

#Preview {
    TerminalTabView()
        .environmentObject(previewWorkspaceConfig())
}
