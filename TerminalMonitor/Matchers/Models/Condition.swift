//
//  Condition.swift
//  TerminalMonitor
//
//  Created on 2025/9/19.
//

import Foundation

class Condition: Identifiable, ObservableObject, NSCopying {
    
    let id: UUID
    
    var name: String? {
        didSet {
            updatePublishedProperties()
        }
    }
    
    @Published var isInverted: Bool
    
    @Published var defaultResult: Bool
    
    @Published var isDisabled: Bool
    
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
        
        updatePublishedProperties()
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
        self.conditionDescription = ""
        
        updatePublishedProperties()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        Condition(self)
    }
    
    private func updatePublishedProperties() {
        self.conditionDescription = self.name ?? ""
    }
}

func previewConditions() -> [Condition] {
    [
        Condition(name: "timestamp"),
        Condition(name: "execution"),
        Condition(name: "plaintext"),
    ]
}
