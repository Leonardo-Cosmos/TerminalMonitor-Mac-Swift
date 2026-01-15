//
//  FrameAlignment.swift
//  TerminalMonitor
//
//  Created on 2025/11/23.
//

import Foundation
import SwiftUI

enum FrameAlignment: String, Codable, CaseIterable, Identifiable {
    case center
    case leading
    case trailing
    case top
    case bottom
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .center:
                "Center"
        case .leading:
                "Leading"
        case .trailing:
                "Trailing"
        case .top:
                "Top"
        case .bottom:
                "Bottom"
        case .topLeading:
                "Top Leading"
        case .topTrailing:
                "Top Trailing"
        case .bottomLeading:
                "Bottom Leading"
        case .bottomTrailing:
                "Bottom Trailing"
        }
    }
    
    var value: Alignment {
        switch self {
        case .center:
                .center
        case .leading:
                .leading
        case .trailing:
                .trailing
        case .top:
                .top
        case .bottom:
                .bottom
        case .topLeading:
                .topLeading
        case .topTrailing:
                .topTrailing
        case .bottomLeading:
                .bottomLeading
        case .bottomTrailing:
                .bottomTrailing
        }
    }
}

