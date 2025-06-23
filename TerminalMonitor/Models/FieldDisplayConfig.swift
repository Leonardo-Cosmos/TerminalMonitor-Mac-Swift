//
//  FieldDisplayDetail.swift
//  TerminalMonitor
//
//  Created on 2025/6/18.
//

import Foundation

class FieldDisplayConfig {
    
    let id: UUID
    
    var fieldKey: String
    
    var headerName: String?
    
    init(id: UUID, fieldKey: String, headerName: String? = nil) {
        self.id = id
        self.fieldKey = fieldKey
        self.headerName = headerName
    }
    
    convenience init(fieldKey: String, headerName: String? = nil) {
        self.init(
            id: UUID(),
            fieldKey: fieldKey,
            headerName: headerName
        )
    }
}
