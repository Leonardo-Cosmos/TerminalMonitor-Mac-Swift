//
//  FieldDisplayDetail.swift
//  TerminalMonitor
//
//  Created on 2025/6/18.
//

import Foundation

class FieldDisplayConfig: Identifiable, ObservableObject {
    
    let id: UUID
    
    var fieldKey: String {
        didSet {
            updatePublishedProperties()
        }
    }
    
    @Published var hidden: Bool
    
    var headerName: String? {
        didSet {
            updatePublishedProperties()
        }
    }
    
    var customizeStyle: Bool
    
    var style: TextStyleConfig
    
    @Published var fieldDescription: String
    
    @Published var fieldColumnHeader: String
    
    init(id: UUID, fieldKey: String, hidden: Bool, headerName: String? = nil, customizeStyle: Bool, style: TextStyleConfig) {
        self.id = id
        self.fieldKey = fieldKey
        self.hidden = hidden
        self.headerName = headerName
        self.customizeStyle = customizeStyle
        self.style = style
        self.fieldDescription = fieldKey
        self.fieldColumnHeader = fieldKey
        
        updatePublishedProperties()
    }
    
    convenience init(fieldKey: String, hidden: Bool = false, headerName: String? = nil, customizeStyle: Bool = false, style: TextStyleConfig) {
        self.init(
            id: UUID(),
            fieldKey: fieldKey,
            hidden: hidden,
            headerName: headerName,
            customizeStyle: customizeStyle,
            style: style
        )
    }
    
    private func updatePublishedProperties() {
        if let headerName = self.headerName {
            self.fieldDescription = "\(self.fieldKey) (\(headerName))"
            self.fieldColumnHeader = headerName
        } else {
            self.fieldDescription = self.fieldKey
            self.fieldColumnHeader = self.fieldKey
        }
    }
}

func previewFieldDisplayConfigs() -> [FieldDisplayConfig] {
    [
        FieldDisplayConfig(fieldKey: "timestamp", style: TextStyleConfig()),
        FieldDisplayConfig(fieldKey: "execution", style: TextStyleConfig()),
        FieldDisplayConfig(fieldKey: "plaintext", style: TextStyleConfig()),
    ]
}
