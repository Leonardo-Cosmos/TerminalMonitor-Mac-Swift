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
    
    func merge(to baseStyle: TextStyleConfig) -> TextStyleConfig {
        let mergedStyle = baseStyle.copy() as! TextStyleConfig
        
        if let foreground = self.foreground {
            mergedStyle.foreground = (foreground.copy() as! TextColorConfig)
        }
        if let background = self.background {
            mergedStyle.background = (background.copy() as! TextColorConfig)
        }
        if let cellBackground = self.cellBackground {
            mergedStyle.cellBackground = (cellBackground.copy() as! TextColorConfig)
        }
        if let alignment = self.alignment {
            mergedStyle.alignment = alignment
        }
        if let lineLimit = self.lineLimit {
            mergedStyle.lineLimit = lineLimit
        }
        if let truncationMode = self.truncationMode {
            mergedStyle.truncationMode = truncationMode
        }
        
        return mergedStyle
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
