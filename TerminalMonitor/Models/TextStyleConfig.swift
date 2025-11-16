//
//  TextStyleConfig.swift
//  TerminalMonitor
//
//  Created on 2025/6/24.
//

import Foundation

class TextStyleConfig: Identifiable, NSCopying {
    
    let id: UUID
    
    var foreground: TextColorConfig?
    
    var background: TextColorConfig?
    
    var lineLimit: Int?
    
    init(id: UUID, foreground: TextColorConfig? = nil, background: TextColorConfig? = nil, lineLimit: Int? = nil) {
        self.id = id
        self.foreground = foreground
        self.background = background
        self.lineLimit = lineLimit
    }
    
    convenience init(foreground: TextColorConfig? = nil, background: TextColorConfig? = nil, lineLimit: Int? = nil) {
        self.init(
            id: UUID(),
            foreground: foreground,
            background: background,
            lineLimit: lineLimit,
        )
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        TextStyleConfig(
            foreground: self.foreground == nil ? nil : (self.foreground!.copy() as! TextColorConfig),
            background: self.background == nil ? nil : (self.background!.copy() as! TextColorConfig),
            lineLimit: self.lineLimit,
        )
    }
    
    static func `default`() -> TextStyleConfig {
        TextStyleConfig(
            foreground: nil,
            background: nil,
            lineLimit: nil,
        )
    }
}
