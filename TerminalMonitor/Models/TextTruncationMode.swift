//
//  TextTruncationMode.swift
//  TerminalMonitor
//
//  Created on 2025/11/16.
//

import Foundation
import SwiftUI

enum TextTruncationMode: CaseIterable, Identifiable, Codable {
    case head
    case tail
    case middle
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .head:
            NSLocalizedString("Head", comment: "")
        case .tail:
            NSLocalizedString("Tail", comment: "")
        case .middle:
            NSLocalizedString("Middle", comment: "")
        }
    }
    
    var mode: Text.TruncationMode {
        switch self {
        case .head:
                .head
        case .tail:
                .tail
        case .middle:
                .middle
        }
    }
}

