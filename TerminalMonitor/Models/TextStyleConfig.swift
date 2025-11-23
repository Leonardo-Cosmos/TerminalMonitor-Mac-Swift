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
    
    var cellBackground: TextColorConfig?
    
    var alignment: FrameAlignment?
    
    var lineLimit: Int?
    
    var truncationMode: TextTruncationMode?
    
    init(id: UUID, foreground: TextColorConfig? = nil, background: TextColorConfig? = nil, cellBackground: TextColorConfig? = nil, alignment: FrameAlignment? = nil, lineLimit: Int? = nil, truncationMode: TextTruncationMode? = nil) {
        self.id = id
        self.foreground = foreground
        self.background = background
        self.cellBackground = cellBackground
        self.alignment = alignment
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
    }
    
    convenience init(foreground: TextColorConfig? = nil, background: TextColorConfig? = nil, cellBackground: TextColorConfig? = nil, alignment: FrameAlignment? = nil, lineLimit: Int? = nil, truncationMode: TextTruncationMode? = nil) {
        self.init(
            id: UUID(),
            foreground: foreground,
            background: background,
            cellBackground: cellBackground,
            alignment: alignment,
            lineLimit: lineLimit,
            truncationMode: truncationMode,
        )
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        TextStyleConfig(
            foreground: self.foreground == nil ? nil : (self.foreground!.copy() as! TextColorConfig),
            background: self.background == nil ? nil : (self.background!.copy() as! TextColorConfig),
            cellBackground: self.cellBackground == nil ? nil : (self.cellBackground!.copy() as! TextColorConfig),
            alignment: self.alignment,
            lineLimit: self.lineLimit,
            truncationMode: self.truncationMode,
        )
    }
    
    static func `default`() -> TextStyleConfig {
        TextStyleConfig(
            foreground: nil,
            background: nil,
            cellBackground: nil,
            alignment: nil,
            lineLimit: nil,
            truncationMode: nil,
        )
    }
}
