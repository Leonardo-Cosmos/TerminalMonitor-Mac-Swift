//
//  FieldListView.swift
//  TerminalMonitor
//
//  Created on 2025/9/10.
//

import SwiftUI
import Flow

struct FieldListView: View {
    
    private static let selectedButtonForeground = Color(nsColor: NSColor.selectedControlTextColor)
    
    private static let unselectedButtonForeground = Color(nsColor: NSColor.controlTextColor)
    
    private static let selectedButtonBackground = Color(nsColor: NSColor.selectedControlColor)
    
    private static let unselectedButtonBackground = Color(nsColor: NSColor.controlColor)
    
    @Binding var visibleFields: [FieldDisplayConfig]
    
    @State private var isExpanded = true
    
    @State private var selectedItems: Set<UUID> = []
    
    @State private var selectedItem: UUID?
    
    @State private var selectMultiItems = false
    
    var onFieldsApplied: ([FieldDisplayConfig]) -> Void
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: {
            HFlow {
                ForEach(visibleFields) { fieldDisplayConfig in
                    FieldListItemView(
                        fieldDisplayConfig: fieldDisplayConfig,
                        onFieldClicked: { onFieldClicked(fieldId: $0) },
                        buttonForeground: buttonForeground,
                        buttonBackground: buttonBackground,
                    )
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            FieldListHelper.openFieldConfigWindow(fieldConfig: fieldDisplayConfig)
                        }
                        .labelStyle(.titleAndIcon)
                    }
                }
            }
        }, label: {
            HStack {
                Text("Fields")
                
                Button("Add", systemImage: "plus") {
                    addField()
                }
                .labelStyle(.iconOnly)
                
                Button("Remove", systemImage: "minus") {
                    removeSelectedField()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Button("Edit", systemImage: "pencil") {
                    editSelectedField()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Button("Move Left", systemImage: "arrowshape.left.fill") {
                    moveSelectedFieldsLeft()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Button("Move Right", systemImage: "arrowshape.right.fill") {
                    moveSelectedFieldsRight()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedItems.isEmpty)
                
                Spacer()
                
                Button("Select", systemImage: selectMultiItems ? "checklist.checked" : "checklist") {
                    if selectMultiItems {
                        selectedItems.removeAll()
                        if let selectedField = selectedItem {
                            selectedItems.insert(selectedField)
                        }
                    }
                    selectMultiItems.toggle()
                }
                .labelStyle(.iconOnly)
                .help(selectMultiItems ? "Multiple Selection" : "Single Selection")
                
                Button("Apply", systemImage: "checkmark") {
                    onFieldsApplied(visibleFields)
                }
                .labelStyle(.iconOnly)
                .help("Apply Field Changes")
            }
        })
        .frame(minWidth: 400)
    }
    
    private func onFieldClicked(fieldId: UUID) {
        if selectMultiItems {
            if selectedItems.contains(fieldId) {
                selectedItems.remove(fieldId)
                if selectedItem == fieldId {
                    selectedItem = nil
                }
            } else {
                selectedItems.insert(fieldId)
                selectedItem = fieldId
            }
        } else {
            if selectedItem == fieldId {
                selectedItem = nil
                selectedItems.removeAll()
            } else {
                selectedItem = fieldId
                selectedItems.removeAll()
                selectedItems.insert(fieldId)
            }
        }
    }
    
    private func buttonForeground(_ fieldId: UUID) -> Color {
        if selectedItems.contains(fieldId) {
            return Self.selectedButtonForeground
        } else {
            return Self.unselectedButtonForeground
        }
    }
    
    private func buttonBackground(_ fieldId: UUID) -> Color {
        if selectedItems.contains(fieldId) {
            return Self.selectedButtonBackground
        } else {
            return Self.unselectedButtonBackground
        }
    }
    
    private func forEachSelectedField(byOrder: Bool = false, reverseOrder: Bool = false,
                                      action: (FieldDisplayConfig) -> Void) {
        var selectedFields: [FieldDisplayConfig] = []
        for fieldId in selectedItems {
            if let selectedField = visibleFields.first(where: { $0.id == fieldId }) {
                selectedFields.append(selectedField)
            }
        }
        
        if byOrder {
            selectedFields.sort(by: { fieldX, fieldY in
                let indexX = visibleFields.firstIndex(where: { $0.id == fieldX.id }) ?? 0
                let indexY = visibleFields.firstIndex(where: { $0.id == fieldY.id }) ?? 0
                return indexX < indexY
            })
        }
        
        if reverseOrder {
            selectedFields.reverse()
        }
        
        for selectedField in selectedFields {
            action(selectedField)
        }
    }
    
    private func addField() {
        FieldListHelper.openFieldConfigWindow { fieldConfig in
            FieldListHelper.addFieldConfig(fieldConfig: fieldConfig, fieldConfigs: &visibleFields, replacing: nil)
        }
    }
    
    private func removeSelectedField() {
        forEachSelectedField { selectedField in
            FieldListHelper.removeFieldConfig(fieldId: selectedField.id, fieldConfigs: &visibleFields)
        }
    }
    
    private func editSelectedField() {
        forEachSelectedField { selectedField in
            FieldListHelper.openFieldConfigWindow(fieldConfig: selectedField)
        }
    }
    
    private func moveSelectedFieldsLeft() {
        forEachSelectedField(byOrder: true, reverseOrder: false) { selectedField in
            FieldListHelper.moveFieldConfigLeft(fieldId: selectedField.id, fieldConfigs: &visibleFields)
        }
    }
    
    private func moveSelectedFieldsRight() {
        forEachSelectedField(byOrder: true, reverseOrder: true) { selectedField in
            FieldListHelper.moveFieldConfigRight(fieldId: selectedField.id, fieldConfigs: &visibleFields)
        }
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
    FieldListView(
        visibleFields: Binding.constant(previewFieldDisplayConfigs()),
        onFieldsApplied: { visibleFields in }
    )
}
