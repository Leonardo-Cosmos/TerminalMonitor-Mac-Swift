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
    
    @State var visibleFields: [FieldDisplayConfig] = []
    
    @State private var isExpanded = true
    
    @State private var selectedItems: Set<UUID> = []
    
    @State private var selectedItem: UUID?
    
    @State private var selectMultiItems = false
    
    var onFieldsApplied: ([FieldDisplayConfig]) -> Void
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: {
            HFlow {
                ForEach(visibleFields) { fieldDisplayConfig in
                    Button(action: { onFieldClicked(fieldId: fieldDisplayConfig.id) }) {
                        HStack {
                            Text(fieldDisplayConfig.fieldDescription)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                        }
                        .foregroundStyle(buttonForeground(fieldDisplayConfig.id))
                        .background(buttonBackground(fieldDisplayConfig.id))
                        .backgroundStyle(buttonBackground(fieldDisplayConfig.id))
                        .opacity(fieldDisplayConfig.hidden ? 0.5 : 1.0)
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

#Preview {
    FieldListView(visibleFields: previewFieldDisplayConfigs(), onFieldsApplied: { visibleFields in })
}
