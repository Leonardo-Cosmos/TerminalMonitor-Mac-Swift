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
                    .padding(.horizontal)
                    
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
                    .padding(.horizontal)
                    
                    HStack {
                        Toggle("", isOn: $viewModel.enableCellBackground)
                        
                        Text("Cell Background")
                        
                        Picker("", selection: $viewModel.cellBackgroundColorMode) {
                            ForEach(TextColorMode.allCases) { colorMode in
                                Text(colorMode.description)
                                    .tag(colorMode)
                            }
                        }
                        .disabled(!viewModel.enableCellBackground)
                        
                        ColorPicker("", selection: $viewModel.cellBackgroundColor)
                            .disabled(!viewModel.enableCellBackground &&
                                      viewModel.cellBackgroundColorMode == .fixed)
                    }
                    .padding(.horizontal)
                }
            }
            
            GroupBox(label: Text("Layout")) {
                HStack {
                    HStack {
                        Toggle("", isOn: $viewModel.enableAlignment)
                        
                        Text("Alignment")
                        
                        Picker("", selection: $viewModel.alignment) {
                            ForEach(FrameAlignment.allCases) { alignment in
                                Text(alignment.description)
                                    .tag(alignment)
                            }
                        }
                        .disabled(!viewModel.enableAlignment)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Toggle("", isOn: $viewModel.enableLineLimit)
                        
                        Text("Line limit (1~10)")
                        
                        NumericTextField(value: $viewModel.lineLimit, minValue: 1, maxValue: 10)
                            .disabled(!viewModel.enableLineLimit)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Toggle("", isOn: $viewModel.enableTruncationMode)
                        
                        Text("Truncation")
                        
                        Picker("", selection: $viewModel.truncationMode) {
                            ForEach(TextTruncationMode.allCases) { truncationMode in
                                Text(truncationMode.description)
                                    .tag(truncationMode)
                            }
                        }
                        .disabled(!viewModel.enableTruncationMode)
                    }
                    .padding(.horizontal)
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
    
    @Published var enableCellBackground: Bool
    
    @Published var cellBackgroundColor: Color
    
    @Published var cellBackgroundColorMode: TextColorMode
    
    @Published var enableAlignment: Bool
    
    @Published var alignment: FrameAlignment
    
    @Published var enableLineLimit: Bool
    
    @Published var lineLimit: Int
    
    @Published var enableTruncationMode: Bool
    
    @Published var truncationMode: TextTruncationMode
    
    init(enableForeground: Bool, foregroundColor: Color, foregroundColorMode: TextColorMode,
         enableBackground: Bool, backgroundColor: Color, backgroundColorMode: TextColorMode,
         enableCellBackground: Bool, cellBackgroundColor: Color, cellBackgroundColorMode: TextColorMode,
         enableAlignment: Bool, alignment: FrameAlignment,
         enableLineLimit: Bool, lineLimit: Int,
         enableTruncationMode: Bool, truncationMode: TextTruncationMode) {
        self.enableForeground = enableForeground
        self.foregroundColor = foregroundColor
        self.foregroundColorMode = foregroundColorMode
        self.enableBackground = enableBackground
        self.backgroundColor = backgroundColor
        self.backgroundColorMode = backgroundColorMode
        self.enableCellBackground = enableCellBackground
        self.cellBackgroundColor = cellBackgroundColor
        self.cellBackgroundColorMode = cellBackgroundColorMode
        self.enableAlignment = enableAlignment
        self.alignment = alignment
        self.enableLineLimit = enableLineLimit
        self.lineLimit = lineLimit
        self.enableTruncationMode = enableTruncationMode
        self.truncationMode = truncationMode
    }
    
    convenience init() {
        self.init(
            enableForeground: false,
            foregroundColor: .primary,
            foregroundColorMode: .fixed,
            enableBackground: false,
            backgroundColor: .clear,
            backgroundColorMode: .fixed,
            enableCellBackground: false,
            cellBackgroundColor: .clear,
            cellBackgroundColorMode: .fixed,
            enableAlignment: false,
            alignment: .center,
            enableLineLimit: false,
            lineLimit: 1,
            enableTruncationMode: false,
            truncationMode: .tail
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
        
        if enableCellBackground {
            if let colorConfig = textStyleConfig.cellBackground {
                colorConfig.mode = cellBackgroundColorMode
                colorConfig.color = cellBackgroundColor
            } else {
                textStyleConfig.cellBackground = TextColorConfig(
                    mode: cellBackgroundColorMode,
                    color: cellBackgroundColor,
                )
            }
        } else {
            textStyleConfig.cellBackground = nil
        }
        
        if enableAlignment {
            textStyleConfig.alignment = alignment
        } else {
            textStyleConfig.alignment = nil
        }
        
        if enableLineLimit {
            textStyleConfig.lineLimit = lineLimit
        } else {
            textStyleConfig.lineLimit = nil
        }
        
        if enableTruncationMode {
            textStyleConfig.truncationMode = truncationMode
        } else {
            textStyleConfig.truncationMode = nil
        }
    }
    
    func to() -> TextStyleConfig {
        let textStyleConfig = TextStyleConfig()
        to(textStyleConfig)
        return textStyleConfig
    }
    
    static func from(_ textStyleConfig: TextStyleConfig) -> TextStyleViewModel {
        TextStyleViewModel(
            enableForeground: textStyleConfig.foreground != nil,
            foregroundColor: textStyleConfig.foreground?.color ?? .primary,
            foregroundColorMode: textStyleConfig.foreground?.mode ?? .fixed,
            enableBackground: textStyleConfig.background != nil,
            backgroundColor: textStyleConfig.background?.color ?? .clear,
            backgroundColorMode: textStyleConfig.background?.mode ?? .fixed,
            enableCellBackground: textStyleConfig.cellBackground != nil,
            cellBackgroundColor: textStyleConfig.cellBackground?.color ?? .clear,
            cellBackgroundColorMode: textStyleConfig.cellBackground?.mode ?? .fixed,
            enableAlignment: textStyleConfig.alignment != nil,
            alignment: textStyleConfig.alignment ?? .center,
            enableLineLimit: textStyleConfig.lineLimit != nil,
            lineLimit: textStyleConfig.lineLimit ?? 1,
            enableTruncationMode: textStyleConfig.truncationMode != nil,
            truncationMode: textStyleConfig.truncationMode ?? .tail,
        )
    }
}

#Preview {
    TextStyleView(viewModel: TextStyleViewModel())
}
