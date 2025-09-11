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
    
    @State private var terminalLineViewer: TerminalLineViewer = TerminalLineSupervisor.shared
    
    @State private var lineViewModels: [TerminalLineViewModel] = []
    
    /**
     A dictionary containing matching result of each line.
     */
    @State private var lineFilterDict: [UUID: Bool] = [:]
    
    /**
     A list of all matched lines.
     */
    @State private var shownLines: [TerminalLine] = []
    
    @State private var selectedLine: UUID?
    
    var body: some View {
        VStack {
            FieldListView(visibleFields: terminalConfig.visibleFields, onFieldsApplied: { visibleFields in
                applyVisibleFields(visibleFields: visibleFields)
            })
            
            Table(lineViewModels, selection: $selectedLine) {
                TableColumnForEach(terminalConfig.visibleFields, id: \.id) { fieldDisplayConfig in
                    if !fieldDisplayConfig.hidden {
                        TableColumn(fieldDisplayConfig.fieldColumnHeader) { (lineViewModel: TerminalLineViewModel) in
                            let fieldViewModel = lineViewModel.lineFieldDict[fieldDisplayConfig.fieldKey]
                            Text(fieldViewModel?.text ?? "")
                                .lineLimit(nil)
                                .onCondition(fieldViewModel?.background != nil) { view in
                                    view.background(fieldViewModel?.background!)
                                }
                        }
                    }
                }
            }
        }
        .contextMenu {
            Button("Clear All until This") {
                clearTerminal()
            }
            .labelStyle(.titleOnly)
        }
        .onAppear {
            appendMatchedTerminalLines()
        }
        .onReceive(NotificationCenter.default.publisher(for: .terminalLinesAppendedEvent)) { notification in
            if let terminalLines = notification.userInfo?[NotificationUserInfoKey.terminalLines] as? [TerminalLine] {
                
                appendNewTerminalLines(terminalLines: terminalLines)
                
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.terminalLinesAppendedEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .terminalLinesRemovedEvent)) { notification in
            if let terminalLines = notification.userInfo?[NotificationUserInfoKey.terminalLines] as? [TerminalLine] {
                
                removeClearedTerminalLines(terminalLines: terminalLines)
                
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.terminalLinesRemovedEvent.rawValue)")
            }
        }
    }
    
    private func clearTerminal() {
        
        if let selectedLine = selectedLine {
            terminalLineViewer.removeTerminalLinesUtil(terminalLineId: selectedLine)
        }
    }
    
    private func appendNewTerminalLines(terminalLines: [TerminalLine]) {
        
        for terminalLine in terminalLines {
            appendTerminalLine(terminalLine: terminalLine)
        }
    }
    
    private func removeClearedTerminalLines(terminalLines: [TerminalLine]) {
        let removedLineIdSet = Set(terminalLines.map { $0.id })
        
        for lineId in removedLineIdSet {
            lineFilterDict.removeValue(forKey: lineId)
        }
        
        let remainingLines = shownLines.filter { !removedLineIdSet.contains($0.id) }
        shownLines.removeAll()
        shownLines.append(contentsOf: remainingLines)
        
        lineViewModels.removeAll(where: { removedLineIdSet.contains($0.id) })
    }
    
    private func filterTerminal() {
        
        appendMatchedTerminalLines()
    }
    
    private func applyVisibleFields(visibleFields: [FieldDisplayConfig]) {
        // Save column settings
        
        terminalConfig.visibleFields.removeAll()
        terminalConfig.visibleFields.append(contentsOf: visibleFields)
        
        lineViewModels.removeAll()
        
        appendMatchedTerminalLines()
    }
    
    private func appendMatchedTerminalLines() {
        
        let terminalLines = terminalLineViewer.terminalLines
        for terminalLine in terminalLines {
            shownLines.append(terminalLine)
            appendTerminalLine(terminalLine: terminalLine)
        }
    }
    
    private func appendTerminalLine(terminalLine: TerminalLine) {
        
        let fieldConfigs = terminalConfig.visibleFields
            
        guard !fieldConfigs.isEmpty else {
            return
        }
        
        var lineFieldDict: [String: TerminalFieldViewModel] = [:]
        for fieldDisplayConfig in fieldConfigs {
            if let lineField = terminalLine.lineFieldDict[fieldDisplayConfig.fieldKey] {
                lineFieldDict[lineField.fieldKey] = TerminalFieldViewModel(
                    text: lineField.text,
//                    background: lineField.text.range(of: "[135]", options: .regularExpression) != nil ? .green : nil
                )
            }
        }
        
        lineViewModels.append(TerminalLineViewModel(
            id: terminalLine.id,
            lineFieldDict: lineFieldDict
        ))
    }
}

struct FieldListHelper {
    
    static func openFieldConfigWindow(fieldConfig: FieldDisplayConfig? = nil, onSave: ((FieldDisplayConfig) -> Void)? = nil) {
        
        var fieldConfig = fieldConfig ?? FieldDisplayConfig(fieldKey: "", style: TextStyleConfig())
        
        FieldDisplayDetailWindowController.openWindow(for: Binding(
            get: { fieldConfig },
            set: { fieldConfig = $0 }
        ), onSave: onSave)
    }
    
    static func addFieldConfig(fieldConfig: FieldDisplayConfig, fieldConfigs: inout [FieldDisplayConfig], replacing fieldId: UUID?) {
        
        if let fieldId = fieldId, let index = fieldConfigs.firstIndex(where: { $0.id == fieldId }) {
            fieldConfigs.insert(fieldConfig, at: index)
        } else {
            fieldConfigs.append(fieldConfig)
        }
    }
    
    static func removeFieldConfig(fieldId: UUID, fieldConfigs: inout [FieldDisplayConfig]) {
        
        fieldConfigs.removeAll() { field in field.id == fieldId }
    }
    
    static func moveFieldConfigLeft(fieldId: UUID, fieldConfigs: inout [FieldDisplayConfig]) {
        guard let srcIndex = fieldConfigs.firstIndex(where: { $0.id == fieldId }) else {
            return
        }
        
        let dstIndex = (srcIndex - 1 + fieldConfigs.count) % fieldConfigs.count
        
        let fieldConfig = fieldConfigs[srcIndex]
        fieldConfigs.remove(at: srcIndex)
        fieldConfigs.insert(fieldConfig, at: dstIndex)
    }
    
    static func moveFieldConfigRight(fieldId: UUID, fieldConfigs: inout [FieldDisplayConfig]) {
        guard let srcIndex = fieldConfigs.firstIndex(where: { $0.id == fieldId }) else {
            return
        }
        
        let dstIndex = (srcIndex + 1) % fieldConfigs.count
        
        let fieldConfig = fieldConfigs[srcIndex]
        fieldConfigs.remove(at: srcIndex)
        fieldConfigs.insert(fieldConfig, at: dstIndex)
    }
}

#Preview {
    TerminalView(terminalConfig: previewTerminalConfigs()[0])
}

struct TerminalLineViewModel: Identifiable {
    
    let id: UUID
    
    let lineFieldDict: [String: TerminalFieldViewModel]
}

struct TerminalFieldViewModel: Identifiable {
    
    let id = UUID()
    
    let text: String
    
    let background: Color? = nil
}
