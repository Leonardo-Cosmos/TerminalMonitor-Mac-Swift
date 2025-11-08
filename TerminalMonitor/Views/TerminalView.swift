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
    
    private static let invalidSelectedFoundNumber = "?"
    
    private static let foundNumberSeparator = "/"
    
    private static let beforeFirstFoundNumber = "-"
    
    private static let afterLastFoundNumber = "+"
    
    @ObservedObject var terminalConfig: TerminalConfig
    
    @State private var terminalLineViewer: TerminalLineViewer = TerminalLineSupervisor.shared
    
    @State private var filterCondition = GroupCondition.default()
    
    @State private var findCondition = GroupCondition.default()
    
    @State private var lineViewModels: [TerminalLineViewModel] = []
    
    /**
     A dictionary containing matching result of each line.
     */
    @State private var lineFilterDict: [UUID: Bool] = [:]
    
    /**
     A list of all filtered lines.
     */
    @State private var shownLines: [TerminalLine] = []
    
    /**
     A list of all found lines within filtered lines.
     */
    @State private var foundLines: [(terminalLine: TerminalLine, shownIndex: Int)] = []
    
    @State private var selectedLineId: UUID?
    
    @State private var foundCount: Int = 0
    
    @State private var selectedFoundNumber: String = invalidSelectedFoundNumber
    
    @State private var autoScroll: Bool = false
    
    @State private var lastScrollToLineIndex: Int? = nil
    
    @State private var firstScrollToLineIndex: Int? = nil
    
    @State private var scrollTimer: Timer?
    
    var body: some View {
        VStack {
            FieldListView(visibleFields: terminalConfig.visibleFields, onFieldsApplied: { visibleFields in
                applyVisibleFields(visibleFields: visibleFields)
            })
            
            ConditionListView(title: "Filter", groupCondition: terminalConfig.filterCondition, onApplied: {
                filterTerminal()
            })
            
            ConditionListView(title: "Find", groupCondition: terminalConfig.findCondition, onApplied: {
                findInTerminal()
            })
            
            HStack {
                Spacer()
                
                Text(selectedFoundNumber)
                Text("/")
                Text(foundCount.description)
                
                SymbolButton(systemImage: "chevron.up.2", symbolColor: .primary) {
                    findFirst()
                }
                .help("Find First")
                .disabled(foundCount == 0)
                
                SymbolButton(systemImage: "chevron.up", symbolColor: .primary) {
                    findPrevious()
                }
                .help("Find Previous")
                .disabled(foundCount == 0)
                
                SymbolButton(systemImage: "chevron.down", symbolColor: .primary) {
                    findNext()
                }
                .help("Find Next")
                .disabled(foundCount == 0)
                
                SymbolButton(systemImage: "chevron.down.2", symbolColor: .primary) {
                    findLast()
                }
                .help("Find Last")
                .disabled(foundCount == 0)
            }
            
            ScrollViewReader { proxy in
                Table(lineViewModels, selection: $selectedLineId) {
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
                .onChange(of: selectedLineId) {
                    updateSelectedFoundNumber()
                }
                .onChange(of: lastScrollToLineIndex) {
                    guard let shownIndex = lastScrollToLineIndex else {
                        return
                    }
                    
                    lastScrollToLineIndex = nil
                    
                    let terminalLine = shownLines[shownIndex]
                    proxy.scrollTo(terminalLine.id, anchor: .bottom)
                }
                .onChange(of: firstScrollToLineIndex) {
                    guard let shownIndex = firstScrollToLineIndex else {
                        return
                    }
                    
                    firstScrollToLineIndex = nil
                    
                    let terminalLine = shownLines[shownIndex]
                    proxy.scrollTo(terminalLine.id, anchor: .top)
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
            findCondition = terminalConfig.findCondition
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
    
    private static func selectedFoundNumberDescription(gte start: Int? = nil, lte end: Int? = nil) -> String {
        if let start = start, let end = end {
            if start == end {
                return start.description
            }
        }
        return "(\(start?.description ?? Self.beforeFirstFoundNumber), \(end?.description ?? Self.afterLastFoundNumber))"
    }
    
    private func clearTerminal() {
        
        if let selectedLine = selectedLineId {
            terminalLineViewer.removeTerminalLinesUtil(terminalLineId: selectedLine)
        }
    }
    
    private func appendNewTerminalLines(terminalLines: [TerminalLine]) {
        
        var isAnyAdded = false
        for terminalLine in terminalLines {
            let matched = TerminalLineMatcher.matches(terminalLine: terminalLine, groupCondition: filterCondition)
            lineFilterDict[terminalLine.id] = matched
            
            if matched {
                shownLines.append(terminalLine)
                appendTerminalLine(terminalLine: terminalLine)
                isAnyAdded = true
            }
        }
        
        if autoScroll && isAnyAdded {
            lastScrollToLineIndex = shownLines.count - 1
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
        
        findInTerminal()
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
        
        findInTerminal()
    }
    
    private func findInTerminal() {
        findCondition = terminalConfig.findCondition
        foundLines.removeAll()
        
        let matcher = TerminalLineMatcher(matchCondition: findCondition)
        for (index, terminalLine) in shownLines.enumerated() {
            let found = matcher.matches(terminalLine: terminalLine)
            if found {
                foundLines.append((terminalLine, shownIndex: index))
            }
        }
        foundCount = foundLines.count
        
        updateSelectedFoundNumber()
    }
    
    private func updateSelectedFoundNumber() {
        
        guard !foundLines.isEmpty else {
            selectedFoundNumber = Self.invalidSelectedFoundNumber
            return
        }
        
        guard let selectedShownIndex = selectedShownLineIndex() else {
            selectedFoundNumber = Self.invalidSelectedFoundNumber
            return
        }
        
        if selectedShownIndex < foundLines.first!.shownIndex {
            selectedFoundNumber = Self.selectedFoundNumberDescription(lte: 1)
            
        } else if selectedShownIndex > foundLines.last!.shownIndex {
            selectedFoundNumber = Self.selectedFoundNumberDescription(gte: foundLines.count)
            
        } else {
            for (index, (_, shownIndex)) in foundLines.enumerated() {
                if shownIndex == selectedShownIndex {
                    selectedFoundNumber = Self.selectedFoundNumberDescription(gte: index + 1, lte: index + 1)
                    break;
                } else if (shownIndex > selectedShownIndex) {
                    selectedFoundNumber = Self.selectedFoundNumberDescription(gte: index, lte: index + 1)
                    break;
                }
            }
        }
    }
    
    private func selectedShownLineIndex() -> Int? {
        shownLines.firstIndex(where: { $0.id == selectedLineId })
    }
    
    private func findPrevious() {
        
        guard !foundLines.isEmpty else {
            return
        }
        
        guard let selectedShownIndex = selectedShownLineIndex() else {
            findLast()
            return
        }
        
        for (terminalLine, shownIndex) in foundLines.reversed() {
            if shownIndex < selectedShownIndex {
                selectedLineId = terminalLine.id
                firstScrollToLineIndex = shownIndex
                
                return
            }
        }
        
        findLast()
    }
    
    private func findNext() {
        
        guard !foundLines.isEmpty else {
            return
        }
        
        guard let selectedShownIndex = selectedShownLineIndex() else {
            findFirst()
            return
        }
        
        for (terminalLine, shownIndex) in foundLines {
            if shownIndex > selectedShownIndex {
                selectedLineId = terminalLine.id
                lastScrollToLineIndex = shownIndex
                
                return
            }
        }
        
        findFirst()
    }
    
    private func findFirst() {
        
        guard !foundLines.isEmpty else {
            return
        }
        
        let (terminalLine, shownIndex) = foundLines.first!
        if let selectedShownIndex = selectedShownLineIndex() {
            if selectedShownIndex == shownIndex {
                return
            }
        }
        
        selectedLineId = terminalLine.id
        firstScrollToLineIndex = shownIndex
    }
    
    private func findLast() {
        
        guard !foundLines.isEmpty else {
            return
        }
        
        let (terminalLine, shownIndex) = foundLines.last!
        if let selectedShownIndex = selectedShownLineIndex() {
            if selectedShownIndex == shownIndex {
                return
            }
        }
        
        selectedLineId = terminalLine.id
        lastScrollToLineIndex = shownIndex
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
