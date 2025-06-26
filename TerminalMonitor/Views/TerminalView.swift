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
    
    @State private var visibleFields: [FieldDisplayConfig] = []
    
    @State private var lineFilterDict: [UUID: Bool] = [:]
    
    @State private var shownLines: [TerminalLine] = []
    
    @State private var isFieldsListExpanded = true
    
    @State private var selectedFields: Set<UUID> = []
    
    @State private var lastSelectedField: UUID?
    
    @State private var selectedLine: UUID?
    
    var body: some View {
        VStack {
            DisclosureGroup(isExpanded: $isFieldsListExpanded, content: {
                HStack {
                    ForEach(visibleFields) { fieldDisplayConfig in
                        Button(action: {
                            let fieldId = fieldDisplayConfig.id
                            if selectedFields.contains(fieldId) {
                                selectedFields.remove(fieldId)
                                if lastSelectedField == fieldId {
                                    lastSelectedField = nil
                                }
                            } else {
                                selectedFields.insert(fieldId)
                                lastSelectedField = fieldId
                            }
                        }) {
                            Text(fieldDisplayConfig.fieldKey)
//                                .foregroundStyle(Color(nsColor: NSColor.alternateSelectedControlTextColor))
                                .background(selectedFields.contains(fieldDisplayConfig.id) ?  Color(nsColor: NSColor.selectedControlColor) : .clear)
//                                .padding(.horizontal, 4)
//                                .padding(.vertical, 4)
//                                .padding()
                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                
                            }
                            .labelStyle(.titleAndIcon)
                        }
                    }
                }
            },
                            label: {
                HStack {
                    Text("Fields")
                    
                    Button("Add", systemImage: "plus") {
                        FieldListHelper.openFieldConfigWindow { fieldConfig in
                            FieldListHelper.addFieldConfig(fieldConfig: fieldConfig, fieldConfigs: &visibleFields, replacing: nil)
                        }
                    }
                    .labelStyle(.iconOnly)
                    
                    Button("Remove", systemImage: "minus") {
                        if let fieldId = lastSelectedField {
                            FieldListHelper.removeFieldConfig(fieldId: fieldId, fieldConfigs: &visibleFields)
                        }
                    }
                    .labelStyle(.iconOnly)
                    .disabled(selectedFields.isEmpty)
                    
                    Button("Edit", systemImage: "pencil") {
                        if let selectedFieldConfig = visibleFields.first(where: { $0.id == lastSelectedField }) {
                            FieldListHelper.openFieldConfigWindow(fieldConfig: selectedFieldConfig)
                        }
                    }
                    .labelStyle(.iconOnly)
                    .disabled(selectedFields.isEmpty)
                    
                    Button("Move Left", systemImage: "arrowshape.left.fill") {
                        
                    }
                    .labelStyle(.iconOnly)
                    .disabled(selectedFields.isEmpty)
                    
                    Button("Move Right", systemImage: "arrowshape.right.fill") {
                        
                    }
                    .labelStyle(.iconOnly)
                    .disabled(selectedFields.isEmpty)
                    
                    Spacer()
                    
                    Button("Apply", systemImage: "checkmark") {
                        applyVisibleFields()
                    }
                    .labelStyle(.iconOnly)
                }
            })
            .contextMenu {
                Button("Add", systemImage: "plus") {
                    
                }
                .labelStyle(.titleAndIcon)
            }
            
            Table(lineViewModels, selection: $selectedLine) {
                TableColumnForEach(terminalConfig.visibleFields, id: \.id) { fieldDisplayConfig in
                    
                    TableColumn(fieldDisplayConfig.fieldKey) { (lineViewModel: TerminalLineViewModel) in
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
        .toolbar {
            Button("Clear", systemImage: "trash") {
                clearTerminal()
            }
            .labelStyle(.iconOnly)
        }
        .onAppear {
            visibleFields = terminalConfig.visibleFields
        }
        .onReceive(NotificationCenter.default.publisher(for: .terminalLinesAppendedEvent)) { notification in
            if let terminalLines = notification.userInfo?[NotificationUserInfoKey.terminalLines] as? [TerminalLine] {
                
                appendNewTerminalLines(terminalLines: terminalLines)
                
            } else {
                Self.logger.error("Missing userInfo in \(Notification.Name.terminalLinesAppendedEvent.rawValue)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .terminalLinesRemovedEvent)) { notification in
            filterTerminal()
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
    
    private func filterTerminal() {
        
        appendMatchedTerminalLines()
    }
    
    private func applyVisibleFields() {
        // Save column settings
        
        appendMatchedTerminalLines()
        
        terminalConfig.visibleFields = visibleFields
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
