//
//  Condition.swift
//  TerminalMonitor
//
//  Created on 2025/9/19.
//

import Foundation

class Condition: Identifiable, NSCopying {
    
    let id: UUID
    
    var name: String?
    
    var isInverted: Bool = false
    
    var defaultResult: Bool = false
    
    var isDisabled: Bool = false
    
    init(id: UUID, name: String?) {
        self.id = id
        self.name = name
    }
    
    convenience init(name: String?) {
        self.init(
            id: UUID(),
            name: name,
        )
    }
    
    convenience init() {
        self.init(
            name: nil,
        )
    }
    
    init(_ obj: Condition) {
        self.id = UUID()
        self.name = obj.name
        self.isInverted = obj.isInverted
        self.defaultResult = obj.defaultResult
        self.isDisabled = obj.isDisabled
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        Condition(self)
    }
}

func previewConditions() -> [Condition] {
    [
        Condition(name: "timestamp"),
        Condition(name: "execution"),
        Condition(name: "plaintext"),
    ]
}
