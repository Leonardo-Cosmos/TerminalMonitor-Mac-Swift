//
//  ViewExtension.swift
//  TerminalMonitor
//
//  Created on 2025/6/4.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func onCondition<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
