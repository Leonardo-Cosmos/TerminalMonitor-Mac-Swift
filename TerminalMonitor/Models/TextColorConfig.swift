//
//  TextColorConfig.swift
//  TerminalMonitor
//
//  Created on 2025/11/13.
//

import Foundation
import SwiftUI

class TextColorConfig: Identifiable, NSCopying {
    
    let id: UUID
    
    var mode: TextColorMode
    
    var color: Color?
    
    init(id: UUID, mode: TextColorMode, color: Color? = nil) {
        self.id = id
        self.mode = mode
        self.color = color
    }
    
    convenience init(mode: TextColorMode, color: Color? = nil) {
        self.init(
            id: UUID(),
            mode: mode,
            color: color
        )
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        TextColorConfig(
            mode: self.mode,
            color: self.color
        )
    }
}
