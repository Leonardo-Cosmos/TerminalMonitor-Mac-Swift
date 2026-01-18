//
//  TextColorMode.swift
//  TerminalMonitor
//
//  Created on 2025/11/13.
//

import Foundation

enum TextColorMode: String, Codable, CaseIterable, Identifiable {
    case fixed
    case hash
    case hashInverted
    case hashSymmetric
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .fixed:
            NSLocalizedString("fixed", comment: "")
        case .hash:
            NSLocalizedString("hash", comment: "")
        case .hashInverted:
            NSLocalizedString("hash inverted", comment: "")
        case .hashSymmetric:
            NSLocalizedString("hash symmetric", comment: "")
        }
    }
}
