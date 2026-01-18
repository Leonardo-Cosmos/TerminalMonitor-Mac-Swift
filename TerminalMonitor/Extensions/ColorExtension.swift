//
//  ColorExtension.swift
//  TerminalMonitor
//
//  Created on 2026/1/18.
//

import Foundation
import SwiftUI

extension Color {
    
    init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
        )
    }
    
    func toRGB() -> (red: UInt8, green: UInt8, blue: UInt8)? {
        let nsColor = NSColor(self)
            .usingColorSpace(.sRGB)
        
        guard let color = nsColor else {
            return nil
        }
        
        return (
            red: UInt8(round(color.redComponent * 255)),
            green: UInt8(round(color.greenComponent * 255)),
            blue: UInt8(round(color.blueComponent * 255))
        )
    }
}
