//
//  TerminalConfig.swift
//  TerminalMonitor
//
//  Created on 2025/6/19.
//

import Foundation

class TerminalConfig: Identifiable, ObservableObject {
    
    let id: UUID
    
    var name: String
    
    var visibleFields: [FieldDisplayConfig]?
    
    init(id: UUID, name: String, visibleFields: [FieldDisplayConfig]? = nil) {
        self.id = id
        self.name = name
        self.visibleFields = visibleFields
    }
    
    convenience init(name: String, visibleFields: [FieldDisplayConfig]? = nil) {
        self.init(
            id: UUID(),
            name: name,
            visibleFields: visibleFields
        )
    }
    
    static func `default`() -> TerminalConfig {
        TerminalConfig(
            name: "default"
        )
    }
}
