//
//  FieldListView.swift
//  TerminalMonitor
//
//  Created on 2025/9/10.
//

import SwiftUI

struct FieldListView: View {
    
    @State var visibleFields: [FieldDisplayConfig] = []
    
    @State private var isExpanded = true
    
    @State private var selectedItems: Set<UUID> = []
    
    @State private var selectedItem: UUID?
    
    @State private var selectMultiItems = false
    
    var onFieldsApplied: ([FieldDisplayConfig]) -> Void
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: {
            HStack {
                ForEach(visibleFields) { fieldDisplayConfig in
                    Button(action: { onFieldClicked(fieldId: fieldDisplayConfig.id) }) {
                        HStack {
                            Text(fieldDisplayConfig.fieldDescription)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                        }
                        .foregroundStyle(selectedItems.contains(fieldDisplayConfig.id) ?
                                         Color(nsColor: NSColor.selectedControlTextColor) :
                                            Color(nsColor: NSColor.controlTextColor))
                        .background(selectedItems.contains(fieldDisplayConfig.id) ?
                                    Color(nsColor: NSColor.selectedControlColor) :
                                        Color(nsColor: NSColor.controlColor))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(nsColor: NSColor.lightGray), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            FieldListHelper.openFieldConfigWindow(fieldConfig: fieldDisplayConfig)
                        }
                        .labelStyle(.titleAndIcon)
                    }
                }
            }
            .padding(2)
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
    
    private func addField() {
        FieldListHelper.openFieldConfigWindow { fieldConfig in
            FieldListHelper.addFieldConfig(fieldConfig: fieldConfig, fieldConfigs: &visibleFields, replacing: nil)
        }
    }
    
    private func removeSelectedField() {
        if let fieldId = selectedItem {
            FieldListHelper.removeFieldConfig(fieldId: fieldId, fieldConfigs: &visibleFields)
        }
    }
    
    private func editSelectedField() {
        if let selectedFieldConfig = visibleFields.first(where: { $0.id == selectedItem }) {
            FieldListHelper.openFieldConfigWindow(fieldConfig: selectedFieldConfig)
        }
    }
    
    private func moveSelectedFieldsLeft() {
        let selectedFields = visibleFields.filter { self.selectedItems.contains($0.id)}
        for selectedField in selectedFields {
            FieldListHelper.moveFieldConfigLeft(fieldId: selectedField.id, fieldConfigs: &visibleFields)
        }
    }
    
    private func moveSelectedFieldsRight() {
        let selectedFields = visibleFields.filter { self.selectedItems.contains($0.id)}
        for selectedField in selectedFields {
            FieldListHelper.moveFieldConfigRight(fieldId: selectedField.id, fieldConfigs: &visibleFields)
        }
    }
}

#Preview {
    FieldListView(visibleFields: previewFieldDisplayConfigs(), onFieldsApplied: { visibleFields in })
}
