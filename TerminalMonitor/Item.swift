//
//  Item.swift
//  TerminalMonitor
//
//  Created on 2025/5/8.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
