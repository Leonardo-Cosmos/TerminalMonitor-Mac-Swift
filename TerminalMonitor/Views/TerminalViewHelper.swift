//
//  TerminalViewHelper.swift
//  TerminalMonitor
//
//  Created on 2025/11/30.
//

import Foundation
import SwiftUI

struct TerminalViewHelper {
    
    static func updateFieldDisplayConfigs(from newConfigs: [FieldDisplayConfig],
                                          to oldConfigs: [FieldDisplayConfig]
    ) -> [FieldDisplayConfig] {
        
        var resultConfigs: [FieldDisplayConfig] = []
        
        for newConfig in newConfigs {
            if let config = oldConfigs.first(where: { $0.id == newConfig.id }) {
                newConfig.to(config)
                resultConfigs.append(config)
            } else {
                let config = newConfig.copy(id: newConfig.id)
                resultConfigs.append(config)
            }
        }
        
        return resultConfigs
    }
    
    static func buildTextColor(colorConfig: TextColorConfig, text: String) -> Color? {
        switch colorConfig.mode {
        case .fixed:
            colorConfig.color
        case .hash:
            hashColor(text)
        case .hashInverted:
            invertedColor(hashColor(text))
        case .hashSymmetric:
            symmetricColor(hashColor(text))
        }
    }
    
    private static func hashColor(_ text: String) -> Color {
        let hashValue = text.hashValue
        
        let red = Double(hashValue & 0xFF) / 255.0
        let green = Double((hashValue >> 8) & 0xFF) / 255.0
        let blue = Double((hashValue >> 16) & 0xFF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
    
    private static func invertedColor(_ color: Color) -> Color {
        guard let rgbTuple = color.toRGB() else {
            return color
        }
        
        var (red, green, blue) = rgbTuple
        red ^= 0xFF
        green ^= 0xFF
        blue ^= 0xFF
        
        return Color(red: red, green: green, blue: blue)
    }
    
    private static func symmetricColor(_ color: Color) -> Color {
        guard let rgbTuple = color.toRGB() else {
            return color
        }
        
        var (red, green, blue) = rgbTuple
        red &-= 0x80
        green &-= 0x80
        blue &-= 0x80
        
        return Color(red: red, green: green, blue: blue)
    }
}
