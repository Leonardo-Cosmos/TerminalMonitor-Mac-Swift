//
//  TerminalView.swift
//  TerminalMonitor
//
//  Created on 2025/5/29.
//

import SwiftUI
import os

struct TerminalView: View {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Self.self)
    )
    
    @ObservedObject var terminalConfig: TerminalConfig
    
    @State private var shownLines: [TerminalLineDisplayInfo] = []
    
    @State private var fieldDisplayConfigs: [FieldDisplayConfig] = [
        FieldDisplayConfig(fieldKey: "system.timestamp"),
        FieldDisplayConfig(fieldKey: "system.execution"),
        FieldDisplayConfig(fieldKey: "system.plaintext"),
    ]
    
    var body: some View {
        Table(shownLines) {
            TableColumnForEach(fieldDisplayConfigs, id: \.id) { fieldDisplayConfig in
                
                TableColumn(fieldDisplayConfig.fieldKey) { (lineDisplayInfo: TerminalLineDisplayInfo) in
                    let fieldDisplayInfo = lineDisplayInfo.lineFieldDict[fieldDisplayConfig.fieldKey]
                    Text(fieldDisplayInfo?.text ?? "")
                        .lineLimit(nil)
                        .onCondition(fieldDisplayInfo?.background != nil) { view in
                            view.background(fieldDisplayInfo?.background!)
                        }
                }
            }
        }
        .toolbar {
            Button("Clear", systemImage: "trash") {
                shownLines.removeAll()
            }
            .labelStyle(.iconOnly)
        }
        .onReceive(NotificationCenter.default.publisher(for: .terminalLinesAppendedEvent)) { notification in
            if let terminalLines = notification.userInfo?[NotificationUserInfoKey.terminalLines] as? [TerminalLine] {
                
                let terminalLineDisplayConfigs = terminalLines.map { buildDisplayConfig(terminalLine: $0) }
                shownLines.append(contentsOf: terminalLineDisplayConfigs)
                
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.terminalLinesAppendedEvent.rawValue)")
            }
        }
    }
    
    private func buildDisplayConfig(terminalLine: TerminalLine) -> TerminalLineDisplayInfo {
        
        var lineFieldDict: [String: TerminalFieldDisplayInfo] = [:]
        for fieldDisplayConfig in fieldDisplayConfigs {
            if let lineField = terminalLine.lineFieldDict[fieldDisplayConfig.fieldKey] {
                lineFieldDict[lineField.fieldKey] = TerminalFieldDisplayInfo(
                    text: lineField.text,
//                    background: lineField.text.range(of: "[135]", options: .regularExpression) != nil ? .green : nil
                )
            }
        }
        
        return TerminalLineDisplayInfo(lineFieldDict: lineFieldDict)
    }
}

#Preview {
    TerminalView(terminalConfig: TerminalConfig(name: "Console"))
}

struct TerminalLineDisplayInfo: Identifiable {
    
    let id = UUID()
    
    let lineFieldDict: [String: TerminalFieldDisplayInfo]
}

struct TerminalFieldDisplayInfo: Identifiable {
    
    let id = UUID()
    
    let text: String
    
    let background: Color? = nil
}
