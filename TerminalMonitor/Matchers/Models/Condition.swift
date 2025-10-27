//
//  Condition.swift
//  TerminalMonitor
//
//  Created on 2025/9/19.
//

import Foundation

class Condition: Identifiable, ObservableObject, NSCopying {
    
    let id: UUID
    
    var name: String?
    
    var isInverted: Bool
    
    var defaultResult: Bool
    
    var isDisabled: Bool
    
    @Published var conditionDescription: String
    
    init(id: UUID, name: String?,
         isInverted: Bool = false,
         defaultResult: Bool = false,
         isDisabled: Bool = false) {
        self.id = id
        self.name = name
        self.conditionDescription = ""
        self.isInverted = isInverted
        self.defaultResult = defaultResult
        self.isDisabled = isDisabled
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
        
        self.conditionDescription = obj.conditionDescription
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
