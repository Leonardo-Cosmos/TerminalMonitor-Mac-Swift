//
//  FieldListView.swift
//  TerminalMonitor
//
//  Created on 2025/9/10.
//

import SwiftUI

struct FieldListView: View {
    
    @State var visibleFields: [FieldDisplayConfig] = []
    
    @State private var isFieldsListExpanded = true
    
    @State private var selectedFields: Set<UUID> = []
    
    @State private var selectedField: UUID?
    
    @State private var selectMultiFields = false
    
    var onFieldsApplied: ([FieldDisplayConfig]) -> Void
    
    var body: some View {
        DisclosureGroup(isExpanded: $isFieldsListExpanded, content: {
            HStack {
                ForEach(visibleFields) { fieldDisplayConfig in
                    Button(action: { onFieldClicked(fieldId: fieldDisplayConfig.id) }) {
                        HStack {
                            Text(fieldDisplayConfig.fieldDescription)
                            //                                .foregroundStyle(Color(nsColor: NSColor.alternateSelectedControlTextColor))
                                .background(selectedFields.contains(fieldDisplayConfig.id) ?  Color(nsColor: NSColor.selectedControlColor) : .clear)
                            //                                .padding(.horizontal, 4)
                            //                                .padding(.vertical, 4)
                            //                                .padding()
                        }
                    }
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
                .disabled(selectedFields.isEmpty)
                
                Button("Edit", systemImage: "pencil") {
                    editSelectedField()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedFields.isEmpty)
                
                Button("Move Left", systemImage: "arrowshape.left.fill") {
                    moveSelectedFieldsLeft()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedFields.isEmpty)
                
                Button("Move Right", systemImage: "arrowshape.right.fill") {
                    moveSelectedFieldsRight()
                }
                .labelStyle(.iconOnly)
                .disabled(selectedFields.isEmpty)
                
                Spacer()
                
                Button("Select", systemImage: selectMultiFields ? "checklist.checked" : "checklist") {
                    if selectMultiFields {
                        selectedFields.removeAll()
                        if let selectedField = selectedField {
                            selectedFields.insert(selectedField)
                        }
                    }
                    selectMultiFields.toggle()
                }
                .labelStyle(.iconOnly)
                .help(selectMultiFields ? "Multiple Selection" : "Single Selection")
                
                Button("Apply", systemImage: "checkmark") {
                    onFieldsApplied(visibleFields)
                }
                .labelStyle(.iconOnly)
                .help("Apply Field Changes")
            }
        })
    }
    
    private func onFieldClicked(fieldId: UUID) {
        if selectMultiFields {
            if selectedFields.contains(fieldId) {
                selectedFields.remove(fieldId)
                if selectedField == fieldId {
                    selectedField = nil
                }
            } else {
                selectedFields.insert(fieldId)
                selectedField = fieldId
            }
        } else {
            if selectedField == fieldId {
                selectedField = nil
                selectedFields.removeAll()
            } else {
                selectedField = fieldId
                selectedFields.removeAll()
                selectedFields.insert(fieldId)
            }
        }
    }
    
    private func addField() {
        FieldListHelper.openFieldConfigWindow { fieldConfig in
            FieldListHelper.addFieldConfig(fieldConfig: fieldConfig, fieldConfigs: &visibleFields, replacing: nil)
        }
    }
    
    private func removeSelectedField() {
        if let fieldId = selectedField {
            FieldListHelper.removeFieldConfig(fieldId: fieldId, fieldConfigs: &visibleFields)
        }
    }
    
    private func editSelectedField() {
        if let selectedFieldConfig = visibleFields.first(where: { $0.id == selectedField }) {
            FieldListHelper.openFieldConfigWindow(fieldConfig: selectedFieldConfig)
        }
    }
    
    private func moveSelectedFieldsLeft() {
        let selectedFields = visibleFields.filter { self.selectedFields.contains($0.id)}
        for selectedField in selectedFields {
            FieldListHelper.moveFieldConfigLeft(fieldId: selectedField.id, fieldConfigs: &visibleFields)
        }
    }
    
    private func moveSelectedFieldsRight() {
        let selectedFields = visibleFields.filter { self.selectedFields.contains($0.id)}
        for selectedField in selectedFields {
            FieldListHelper.moveFieldConfigRight(fieldId: selectedField.id, fieldConfigs: &visibleFields)
        }
    }
}

#Preview {
    FieldListView(visibleFields: previewFieldDisplayConfigs(), onFieldsApplied: { visibleFields in })
}
