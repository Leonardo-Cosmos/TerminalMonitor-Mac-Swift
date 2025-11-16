//
//  TextStyleView.swift
//  TerminalMonitor
//
//  Created on 2025/6/24.
//

import SwiftUI

struct TextStyleView: View {
    
    @ObservedObject var viewModel: TextStyleViewModel
    
    var body: some View {
        VStack {
            GroupBox(label: Text("Color")) {
                HStack {
                    HStack {
                        Toggle("", isOn: $viewModel.enableForeground)
                        
                        Text("Foreground")
                        
                        Picker("", selection: $viewModel.foregroundColorMode) {
                            ForEach(TextColorMode.allCases) { colorMode in
                                Text(colorMode.description)
                                    .tag(colorMode)
                            }
                        }
                        .disabled(!viewModel.enableForeground)
                        
                        ColorPicker("", selection: $viewModel.foregroundColor)
                            .disabled(!viewModel.enableForeground &&
                                      viewModel.foregroundColorMode == .fixed)
                    }
                    .padding()
                    
                    HStack {
                        Toggle("", isOn: $viewModel.enableBackground)
                        
                        Text("Background")
                        
                        Picker("", selection: $viewModel.backgroundColorMode) {
                            ForEach(TextColorMode.allCases) { colorMode in
                                Text(colorMode.description)
                                    .tag(colorMode)
                            }
                        }
                        .disabled(!viewModel.enableBackground)
                        
                        ColorPicker("", selection: $viewModel.backgroundColor)
                            .disabled(!viewModel.enableBackground &&
                                      viewModel.backgroundColorMode == .fixed)
                    }
                    .padding()
                }
            }
            
            GroupBox(label: Text("Layout")) {
                HStack {
                    Toggle("", isOn: $viewModel.enableLineLimit)
                    
                    Text("Line limit (1~10)")
                    
                    NumericTextField(value: $viewModel.lineLimit, minValue: 1, maxValue: 10)
                        .disabled(!viewModel.enableLineLimit)
                }
            }
        }
    }
}

class TextStyleViewModel: ObservableObject {
    
    @Published var enableForeground: Bool
    
    @Published var foregroundColor: Color
    
    @Published var foregroundColorMode: TextColorMode
    
    @Published var enableBackground: Bool
    
    @Published var backgroundColor: Color
    
    @Published var backgroundColorMode: TextColorMode
    
    @Published var enableLineLimit: Bool
    
    @Published var lineLimit: Int
    
    init(enableForeground: Bool, foregroundColor: Color, foregroundColorMode: TextColorMode,
         enableBackground: Bool, backgroundColor: Color, backgroundColorMode: TextColorMode,
         enableLineLimit: Bool, lineLimit: Int) {
        self.enableForeground = enableForeground
        self.foregroundColor = foregroundColor
        self.foregroundColorMode = foregroundColorMode
        self.enableBackground = enableBackground
        self.backgroundColor = backgroundColor
        self.backgroundColorMode = backgroundColorMode
        self.enableLineLimit = enableLineLimit
        self.lineLimit = lineLimit
    }
    
    convenience init() {
        self.init(
            enableForeground: false,
            foregroundColor: .primary,
            foregroundColorMode: .fixed,
            enableBackground: false,
            backgroundColor: .clear,
            backgroundColorMode: .fixed,
            enableLineLimit: false,
            lineLimit: 1
        )
    }
    
    static func from(_ textStyleConfig: TextStyleConfig) -> TextStyleViewModel {
        TextStyleViewModel(
            enableForeground: textStyleConfig.foreground != nil,
            foregroundColor: textStyleConfig.foreground?.color ?? .primary,
            foregroundColorMode: textStyleConfig.foreground?.mode ?? .fixed,
            enableBackground: textStyleConfig.background != nil,
            backgroundColor: textStyleConfig.background?.color ?? .clear,
            backgroundColorMode: textStyleConfig.background?.mode ?? .fixed,
            enableLineLimit: textStyleConfig.lineLimit != nil,
            lineLimit: textStyleConfig.lineLimit ?? 1,
        )
    }
    
    func to(_ textStyleConfig: TextStyleConfig) {
        if enableForeground {
            if let colorConfig = textStyleConfig.foreground {
                colorConfig.mode = foregroundColorMode
                colorConfig.color = foregroundColor
            } else {
                textStyleConfig.foreground = TextColorConfig(
                    mode: foregroundColorMode,
                    color: foregroundColor,
                )
            }
        } else {
            textStyleConfig.foreground = nil
        }
        
        if enableBackground {
            if let colorConfig = textStyleConfig.background {
                colorConfig.mode = backgroundColorMode
                colorConfig.color = backgroundColor
            } else {
                textStyleConfig.background = TextColorConfig(
                    mode: backgroundColorMode,
                    color: backgroundColor,
                )
            }
        } else {
            textStyleConfig.background = nil
        }
        
        if enableLineLimit {
            textStyleConfig.lineLimit = lineLimit
        } else {
            textStyleConfig.lineLimit = nil
        }
    }
}

#Preview {
    TextStyleView(viewModel: TextStyleViewModel())
}
