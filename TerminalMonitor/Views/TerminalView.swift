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
    
    @State private var filterCondition = GroupCondition.default()
    
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
    
    @State private var autoScroll: Bool = false
    
    @State private var lastLineId: UUID? = nil
    
    @State private var scrollTimer: Timer?
    
    var body: some View {
        VStack {
            FieldListView(visibleFields: terminalConfig.visibleFields, onFieldsApplied: { visibleFields in
                applyVisibleFields(visibleFields: visibleFields)
            })
            
            ConditionListView(title: "Filter", groupCondition: terminalConfig.filterCondition, onApplied: {
                filterTerminal()
            })
            
            ScrollViewReader { proxy in
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
                .onChange(of: lastLineId) {
                    guard let lastLineId = lineViewModels.last?.id else {
                        return
                    }
                    proxy.scrollTo(lastLineId, anchor: .bottom)
                }
            }
        }
        .contextMenu {
            SymbolLabelButton(titleKey: "Clear All until This", systemImage: "trash", symbolColor: Color(nsColor: .black)) {
                clearTerminal()
            }
            
            if autoScroll {
                SymbolLabelButton(titleKey: "Auto Scroll", systemImage: "checkmark", symbolColor: Color(nsColor: .black)) {
                    autoScroll = false
                }
            } else {
                SymbolLabelButton(titleKey: "Auto Scroll", systemImage: "square", symbolColor: Color(nsColor: .clear)) {
                    autoScroll = true
                }
            }
        }
        .onAppear {
            filterCondition = terminalConfig.filterCondition
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
        
        var lastAppendedLineId: UUID? = nil
        for terminalLine in terminalLines {
            let matched = TerminalLineMatcher.matches(terminalLine: terminalLine, groupCondition: filterCondition)
            lineFilterDict[terminalLine.id] = matched
            
            if matched {
                shownLines.append(terminalLine)
                appendTerminalLine(terminalLine: terminalLine)
                lastAppendedLineId = terminalLine.id
            }
        }
        
        if autoScroll && lastAppendedLineId != nil {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                Task { @MainActor in
                    self.lastLineId = lastAppendedLineId
                }
            }
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
        
//        findInTerminal()
    }
    
    private func filterTerminal() {
        filterCondition = terminalConfig.filterCondition
        
        lineViewModels.removeAll()
        
        lineFilterDict.removeAll()
        shownLines.removeAll()
        
        let matcher = TerminalLineMatcher(matchCondition: filterCondition)
        for terminalLine in terminalLineViewer.terminalLines {
            let matched = matcher.matches(terminalLine: terminalLine)
            lineFilterDict[terminalLine.id] = matched
            
            if matched {
                shownLines.append(terminalLine)
            }
        }
        
        appendMatchedTerminalLines()
        
//        findInTerminal()
    }
    
    private func applyVisibleFields(visibleFields: [FieldDisplayConfig]) {
        // Save column settings
        
        terminalConfig.visibleFields.removeAll()
        terminalConfig.visibleFields.append(contentsOf: visibleFields)
        
        lineViewModels.removeAll()
        
        appendMatchedTerminalLines()
    }
    
    private func appendMatchedTerminalLines() {
        func matchLine(_ terminalLine: TerminalLine) -> Bool {
            let matched = TerminalLineMatcher.matches(
                terminalLine: terminalLine, matchCondition: filterCondition)
            
            if matched {
                shownLines.append(terminalLine)
            }
            return matched
        }
        
        let terminalLines = terminalLineViewer.terminalLines
        for terminalLine in terminalLines {
            let matched = lineFilterDict[terminalLine.id] ?? matchLine(terminalLine)
            if matched {
                appendTerminalLine(terminalLine: terminalLine)
            }
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
