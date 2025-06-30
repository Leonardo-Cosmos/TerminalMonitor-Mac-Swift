//
//  FieldDisplayDetail.swift
//  TerminalMonitor
//
//  Created on 2025/6/18.
//

import Foundation

class FieldDisplayConfig: Identifiable, ObservableObject {
    
    let id: UUID
    
    @Published var fieldKey: String
    
    @Published var hidden: Bool
    
    var headerName: String?
    
    var customizeStyle: Bool
    
    var style: TextStyleConfig
    
    init(id: UUID, fieldKey: String, hidden: Bool, headerName: String? = nil, customizeStyle: Bool, style: TextStyleConfig) {
        self.id = id
        self.fieldKey = fieldKey
        self.hidden = hidden
        self.headerName = headerName
        self.customizeStyle = customizeStyle
        self.style = style
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
}

func previewFieldDisplayConfigs() -> [FieldDisplayConfig] {
    [
        FieldDisplayConfig(fieldKey: "timestamp", style: TextStyleConfig()),
        FieldDisplayConfig(fieldKey: "execution", style: TextStyleConfig()),
        FieldDisplayConfig(fieldKey: "plaintext", style: TextStyleConfig()),
    ]
}
