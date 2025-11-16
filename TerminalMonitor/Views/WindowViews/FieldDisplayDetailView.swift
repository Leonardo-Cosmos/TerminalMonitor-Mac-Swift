//
//  FieldDisplayDetailView.swift
//  TerminalMonitor
//
//  Created on 2025/6/24.
//

import SwiftUI

struct FieldDisplayDetailView: View {
    
    var window: NSWindow?
    
    @ObservedObject var viewModel: FieldDisplayDetailViewModel
    
    var onSave: (() -> Void)?
    
    var body: some View {
        VStack {
            GroupBox(label: Text("General")) {
                VStack {
                    HStack {
                        Text("Field Key")
                            .frame(width: 80)
                        TextField("Full path of the field", text: $viewModel.fieldKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Header")
                            .frame(width: 80)
                        TextField("Column header", text: $viewModel.headerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Hide this column")
                            .frame(width: 120)
                        Toggle("", isOn: $viewModel.hidden)
                        
                        Spacer()
                    }
                }
            }
            
            GroupBox(label: Text("Text Style")) {
                VStack {
                    HStack {
                        Text("Customize style")
                        Toggle("", isOn: $viewModel.customizeStyle)
                        
                        Spacer()
                    }
                    
                    GroupBox(label: Text("Default")) {
                        TextStyleView(viewModel: viewModel.style)
                    }
                    .disabled(!viewModel.customizeStyle)
                }
            }
            
            HStack {
                Button("Cancel") {
                    window?.close()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    onSave?()
                    window?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(minWidth: 400)
    }
}

class FieldDisplayDetailViewModel: ObservableObject {
    
    @Published var fieldKey: String
    
    @Published var hidden: Bool
    
    @Published var headerName: String
    
    @Published var customizeStyle: Bool
    
    @Published var style: TextStyleViewModel
    
    init(fieldKey: String, hidden: Bool, headerName: String, customizeStyle: Bool, style: TextStyleViewModel) {
        self.fieldKey = fieldKey
        self.hidden = hidden
        self.headerName = headerName
        self.customizeStyle = customizeStyle
        self.style = style
    }
    
    convenience init(fieldKey: String) {
        self.init(
            fieldKey: fieldKey,
            hidden: false,
            headerName: "",
            customizeStyle: false,
            style: TextStyleViewModel()
        )
    }
    
    static func from(_ fieldDisplayConfig: FieldDisplayConfig) -> FieldDisplayDetailViewModel {
        FieldDisplayDetailViewModel(
            fieldKey: fieldDisplayConfig.fieldKey,
            hidden: fieldDisplayConfig.hidden,
            headerName: fieldDisplayConfig.headerName ?? "",
            customizeStyle: fieldDisplayConfig.customizeStyle,
            style: TextStyleViewModel.from(fieldDisplayConfig.style)
        )
    }
    
    func to(_ fieldDisplayConfig: FieldDisplayConfig) {
        fieldDisplayConfig.fieldKey = fieldKey
        fieldDisplayConfig.hidden = hidden
        fieldDisplayConfig.headerName = headerName.isEmpty ? nil : headerName
        fieldDisplayConfig.customizeStyle = customizeStyle
        style.to(fieldDisplayConfig.style)
    }
}

class FieldDisplayDetailWindowController {
    
    static func openWindow(for fieldDisplayConfig: Binding<FieldDisplayConfig>, onSave: ((FieldDisplayConfig) -> Void)? = nil) {
        
        let windowContentRect = NSRect(x: 200, y: 200, width: 400, height: 200)
        let window = NSWindow(
            contentRect: windowContentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let fieldDisplayConfigValue = fieldDisplayConfig.wrappedValue
        let viewModel = FieldDisplayDetailViewModel.from(fieldDisplayConfigValue)
        
        let view = FieldDisplayDetailView(window: window, viewModel: viewModel, onSave: {
          
            viewModel.to(fieldDisplayConfigValue)
            
            onSave?(fieldDisplayConfig.wrappedValue)
        })
        
        let hostingController = NSHostingController(rootView: view)
        window.contentViewController = hostingController
        // Rest window frame after view controller is set
        window.setFrame(windowContentRect, display: true)
        
        let windowController = NSWindowController(window: window)
        windowController.window?.makeKeyAndOrderFront(nil)
        windowController.showWindow(nil)
    }
}

#Preview {
    FieldDisplayDetailView(viewModel: FieldDisplayDetailViewModel(fieldKey: "Key"))
}
