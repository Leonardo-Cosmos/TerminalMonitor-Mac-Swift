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
    
    @State private var selectedTerminal: UUID?
    
    @State private var hoveringTab: UUID?
    
    @State private var isClosingLastTerminal: Bool = false
    
    @State private var closingTerminalId: UUID?
    
    @State private var closingTerminalName: String = ""
    
    @State private var renamingTerminalId: UUID?
    
    @State private var renamingTerminalName: String = ""
    
    @State private var showSheet: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ForEach(workspaceConfig.terminals) { terminalConfig in
                    HStack {
                        Button(action: { onClosingTerminal(terminalId: terminalConfig.id) }) {
                            Label("Close", systemImage: "xmark")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 4)
                        
                        Text(terminalConfig.name)
                            .padding(.vertical, 8)
                            .padding(.trailing, 8)
                    }
                    .border(.black, width: 0.5)
                    .background(tabBackground(terminalConfig.id))
                    .padding(.horizontal, -4)
                    .padding(.vertical, -8)
                    .onTapGesture {
                        selectedTerminal = terminalConfig.id
                    }
                    .onHover { hovering in
                        if hovering {
                            hoveringTab = terminalConfig.id
                        } else {
                            if hoveringTab == terminalConfig.id {
                                hoveringTab = nil
                            }
                        }
                    }
                    .contextMenu {
                        Button("Move Left", systemImage: "arrowshape.left.fill") {
                            moveTerminalLeft(terminalId: terminalConfig.id)
                        }
                        .labelStyle(.titleAndIcon)
                        
                        Button("Move Right", systemImage: "arrowshape.right.fill") {
                            moveTerminalRight(terminalId: terminalConfig.id)
                        }
                        .labelStyle(.titleAndIcon)
                        
                        Button("Rename", systemImage: "pencil") {
                            onRenamingTerminal(terminalId: terminalConfig.id)
                        }
                        .labelStyle(.titleAndIcon)
                        
                        Button("Duplicate", systemImage: "plus.square.on.square") {
                            duplicateTerminal(terminalId: terminalConfig.id)
                        }
                        .labelStyle(.titleAndIcon)
                    }
                    .sheet(isPresented: $showSheet) {
                        if isClosingLastTerminal {
                            ConfirmView(isPresented: $showSheet,
                                        style: .Ok,
                                        message: closeLastTerminalMessage(),
                                        onSubmit: { _ in onCloseLastTerminalDenied() })
                        } else if closingTerminalId != nil {
                            ConfirmView(isPresented: $showSheet,
                                        style: .YesAndNo,
                                        message: closeTerminalMessage(terminalName: closingTerminalName),
                                        onSubmit: onClosedTerminal)
                        } else if renamingTerminalId != nil {
                            TextInputView(isPresented: $showSheet,
                                          text: renamingTerminalName,
                                          onComplete: onRenamedTerminal)
                        }
                    }
                }
                
                Button(action: { appendTerminal() }) {
                    Label("Add", systemImage: "plus")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .border(.black, width: 0.5)
                        .labelStyle(.iconOnly)
                }
                .padding(.horizontal, -4)
                .padding(.vertical, -8)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(0)
            
            Divider()
                .padding(0)
            
            ZStack {
                ForEach(workspaceConfig.terminals) { terminalConfig in
                    TerminalView(terminalConfig: terminalConfig)
                        .background(Color(nsColor: NSColor.windowBackgroundColor))
                        .zIndex(selectedTerminal == terminalConfig.id ? 1 : 0)
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
            selectedTerminal = workspaceConfig.terminals.first?.id
            
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
        if selectedTerminal == tabId {
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
    
    private func closeTerminalMessage(terminalName: String) -> String {
        let format = NSLocalizedString("CloseTerminalMessage", comment: "Message in popup sheet when close terminal")
        return String(format: format, terminalName)
    }
    
    private func closeLastTerminalMessage() -> String {
        NSLocalizedString("CloseLastTerminalMessage", comment: "Message in popup sheet when close last terminal")
    }
    
    private func onClosingTerminal(terminalId: UUID) {
        guard workspaceConfig.terminals.count > 1 else {
            isClosingLastTerminal = true
            showSheet = true
            return
        }
        
        if let terminalConfig = workspaceConfig.getTerminal(id: terminalId) {
            closingTerminalId = terminalId
            closingTerminalName = terminalConfig.name
            showSheet = true
        }
    }
    
    private func onCloseLastTerminalDenied() {
        isClosingLastTerminal = false
    }
    
    private func onClosedTerminal(confirmed: Bool) {
        if confirmed {
            if let closingTerminalId = closingTerminalId {
                workspaceConfig.deleteTerminal(id: closingTerminalId)
            }
        }
        closingTerminalId = nil
        closingTerminalName = ""
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
    
    private func onRenamingTerminal(terminalId: UUID) {
        if let terminalConfig = workspaceConfig.getTerminal(id: terminalId) {
            renamingTerminalId = terminalId
            renamingTerminalName = terminalConfig.name
            showSheet = true
        }
    }
    
    private func onRenamedTerminal(result: TextInputResult) {
        switch result {
        case .cancelled:
            break
        case .saved(let text):
            if let terminalConfig = workspaceConfig.getTerminal(id: renamingTerminalId) {
                terminalConfig.name = text
            }
        }
        renamingTerminalId = nil
        renamingTerminalName = ""
    }
    
    private func duplicateTerminal(terminalId: UUID) {
        if let terminalConfig = workspaceConfig.getTerminal(id: terminalId) {
            let duplicatedTerminal = terminalConfig.copy() as! TerminalConfig
            
            let format = NSLocalizedString("DuplicatedConfigName", comment: "Name format of dupliated terminal")
            let duplicatedName = String(format: format, duplicatedTerminal.name)
            duplicatedTerminal.name = duplicatedName
            
            workspaceConfig.insertTerminal(duplicatedTerminal, nextTo: terminalId)
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
