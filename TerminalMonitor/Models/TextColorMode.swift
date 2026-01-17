//
//  TextColorMode.swift
//  TerminalMonitor
//
//  Created on 2025/11/13.
//

import Foundation

enum TextColorMode: String, Codable, CaseIterable, Identifiable {
    case fixed
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .fixed:
            NSLocalizedString("Fixed", comment: "")
        }
    }
}
