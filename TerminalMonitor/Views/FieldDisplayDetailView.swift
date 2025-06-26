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
            HStack {
                Text("Field Key")
                    .frame(width: 80)
                TextField("Full path of the field", text: $viewModel.fieldKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            HStack {
                Text("Header")
                    .frame(width: 80)
                TextField("Column header", text: $viewModel.headerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            HStack {
                Text("Hide this column")
                    .frame(width: 120)
                Toggle("", isOn: $viewModel.hidden)
                
                Spacer()
            }
            .padding()
            
            Button("Save") {
                onSave?()
                window?.close()
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
}

class FieldDisplayDetailWindowController {
    
    static func openWindow(for fieldDisplayConfig: Binding<FieldDisplayConfig>, onSave: ((FieldDisplayConfig) -> Void)? = nil) {
        
        let windowContentRect = NSRect(x: 200, y: 200, width: 800, height: 200)
        let window = NSWindow(
            contentRect: windowContentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let fieldDisplayConfigValue = fieldDisplayConfig.wrappedValue
        let viewModel = FieldDisplayDetailViewModel(
            fieldKey: fieldDisplayConfigValue.fieldKey,
            hidden: fieldDisplayConfigValue.hidden,
            headerName: fieldDisplayConfigValue.headerName ?? "",
            customizeStyle: fieldDisplayConfigValue.customizeStyle,
            style: TextStyleViewModel()
        )
        
        let view = FieldDisplayDetailView(window: window, viewModel: viewModel, onSave: {
          
            fieldDisplayConfigValue.fieldKey = viewModel.fieldKey
            fieldDisplayConfigValue.hidden = viewModel.hidden
            fieldDisplayConfigValue.headerName = viewModel.headerName
            fieldDisplayConfigValue.customizeStyle = viewModel.customizeStyle
            
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
