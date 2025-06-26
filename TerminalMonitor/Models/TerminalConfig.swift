//
//  TerminalConfig.swift
//  TerminalMonitor
//
//  Created on 2025/6/19.
//

import Foundation

class TerminalConfig: Identifiable, ObservableObject {
    
    let id: UUID
    
    @Published var name: String
    
    @Published var visibleFields: [FieldDisplayConfig] = []
    
    init(id: UUID, name: String, visibleFields: [FieldDisplayConfig] = []) {
        self.id = id
        self.name = name
        self.visibleFields = visibleFields
    }
    
    convenience init(name: String, visibleFields: [FieldDisplayConfig] = []) {
        self.init(
            id: UUID(),
            name: name,
            visibleFields: visibleFields
        )
    }
    
    static func `default`() -> TerminalConfig {
        TerminalConfig(
            name: "Default"
        )
    }
}

func previewTerminalConfigs() -> [TerminalConfig] {
    [
        TerminalConfig(
            name: "Console",
            visibleFields: previewFieldDisplayConfigs()
        ),
        TerminalConfig(
            name: "Application"
        ),
    ]
}
