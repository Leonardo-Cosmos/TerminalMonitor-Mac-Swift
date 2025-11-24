//
//  ColorSetting.swift
//  TerminalMonitor
//
//  Created on 2025/11/16.
//

import Foundation
import SwiftUI

class ColorSetting: Codable {
    
    let red: Double
    
    let green: Double
    
    let blue: Double
    
    let alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

class ColorSettingHelper {
    
    static func save(_ value: Color?) -> ColorSetting? {
        
        guard let value = value else {
            return nil
        }
        
        let nsColor = NSColor(value)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return ColorSetting(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            alpha: Double(alpha),
        )
    }
    
    static func load(_ setting: ColorSetting?) -> Color? {
        
        guard let setting = setting else {
            return nil
        }
        
        return Color(
            red: setting.red,
            green: setting.green,
            blue: setting.blue,
            opacity: setting.alpha
        )
    }
}
