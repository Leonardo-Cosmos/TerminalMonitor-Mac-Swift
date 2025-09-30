//
//  TextMatchOperator.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import Foundation

enum TextMatchOperator: CaseIterable, Identifiable {
    case none
    case equals
    case contains
    case hasPrefix
    case hasSuffix
    case matches
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .none:
            "none"
        case .equals:
            "equals"
        case .contains:
            "contains"
        case .hasPrefix:
            "has prefix"
        case .hasSuffix:
            "has suffix"
        case .matches:
            "matches"
        }
    }
}
