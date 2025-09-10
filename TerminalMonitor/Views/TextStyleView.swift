//
//  TextStyleView.swift
//  TerminalMonitor
//
//  Created on 2025/6/24.
//

import SwiftUI

struct TextStyleView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

class TextStyleViewModel: ObservableObject {
    
    @Published var background: Color
    
    init(background: Color) {
        self.background = background
    }
    
    convenience init() {
        self.init(
            background: .clear
        )
    }
}

#Preview {
    TextStyleView()
}
