//
//  TerminalConfig.swift
//  TerminalMonitor
//
//  Created on 2025/6/19.
//

import Foundation

class TerminalConfig: Identifiable, ObservableObject, NSCopying {
    
    let id: UUID
    
    @Published var name: String
    
    @Published var visibleFields: [FieldDisplayConfig]
    
    @Published var filterCondition: GroupCondition
    
    @Published var findCondition: GroupCondition
    
    init(id: UUID, name: String, visibleFields: [FieldDisplayConfig] = [],
         filterCondition: GroupCondition, findCondition: GroupCondition) {
        self.id = id
        self.name = name
        self.visibleFields = visibleFields
        self.filterCondition = filterCondition
        self.findCondition = findCondition
    }
    
    convenience init(name: String, visibleFields: [FieldDisplayConfig] = [], filterCondition: GroupCondition, findCondition: GroupCondition) {
        self.init(
            id: UUID(),
            name: name,
            visibleFields: visibleFields,
            filterCondition: filterCondition,
            findCondition: findCondition,
        )
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        TerminalConfig(
            name: self.name,
            visibleFields: self.visibleFields.map { $0.copy() as! FieldDisplayConfig },
            filterCondition: self.filterCondition.copy() as! GroupCondition,
            findCondition: self.findCondition.copy() as! GroupCondition,
        )
    }
    
    static func `default`() -> TerminalConfig {
        TerminalConfig(
            name: "Default",
            filterCondition: GroupCondition.default(),
            findCondition: GroupCondition.default(),
        )
    }
}

func previewTerminalConfigs() -> [TerminalConfig] {
    [
        TerminalConfig(
            name: "Console",
            visibleFields: previewFieldDisplayConfigs(),
            filterCondition: previewGroupCondition(),
            findCondition: previewGroupCondition(),
        ),
        TerminalConfig(
            name: "Application",
            filterCondition: GroupCondition.default(),
            findCondition: GroupCondition.default()
        ),
    ]
}
