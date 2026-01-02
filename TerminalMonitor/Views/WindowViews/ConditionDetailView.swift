//
//  ConditionDetailView.swift
//  TerminalMonitor
//
//  Created on 2025/9/23.
//

import SwiftUI

struct ConditionDetailView: View {
    
    var window: NSWindow?
    
    @ObservedObject var viewModel: ConditionDetailViewModel
    
    var onSave: ((ConditionDetailViewModel) -> Void)?
    
    var body: some View {
        VStack {
            Picker("", selection: $viewModel.conditionMode) {
                VStack {
                    HStack {
                        Text("Use single field condition")
                        Spacer()
                    }
                    
                    FieldConditionView(viewModel: viewModel.fieldCondition)
                        .disabled(viewModel.conditionMode != .single)
                }
                .tag(ConditionMode.single)
                .padding(.vertical)
                
                
                VStack {
                    HStack {
                        Text("Use multiple field condition")
                        Spacer()
                    }
                    
                    GroupConditionView(viewModel: viewModel.groupCondition)
                        .disabled(viewModel.conditionMode != .multiple)
                }
                .tag(ConditionMode.multiple)
                
            }
            .pickerStyle(.radioGroup)
            
            HStack {
                Button("Cancel") {
                    window?.close()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    onSave?(viewModel)
                    window?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
    }
}

enum ConditionMode {
    case single
    case multiple
}

class ConditionDetailViewModel: ObservableObject {
    
    @Published var conditionMode: ConditionMode
    
    @Published var fieldCondition: FieldConditionViewModel
    
    @Published var groupCondition: GroupConditionViewModel
    
    init(conditionMode: ConditionMode, fieldCondition: FieldConditionViewModel, groupCondition: GroupConditionViewModel) {
        self.conditionMode = conditionMode
        self.fieldCondition = fieldCondition
        self.groupCondition = groupCondition
    }
    
    convenience init() {
        self.init(
            conditionMode: .single,
            fieldCondition: FieldConditionViewModel(),
            groupCondition: GroupConditionViewModel()
        )
    }
}

class ConditionDetailWindowController {
    
    static func openWindow(for condition: Binding<Condition>, onSave: ((Condition) -> Void)? = nil) {
        
        let windowContentRect = NSRect(x: 200, y: 200, width: 800, height: 200)
        let window = NSWindow(
            contentRect: windowContentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        var viewModel: ConditionDetailViewModel
        let conditionValue = condition.wrappedValue
        var fieldConditionValue: FieldCondition? = nil
        var groupConditionValue: GroupCondition? = nil
        
        if let fieldCondition = conditionValue as? FieldCondition {
            fieldConditionValue = fieldCondition
            let fieldConditionViewModel = FieldConditionViewModel.from(fieldCondition)
            
            viewModel = ConditionDetailViewModel(
                conditionMode: .single,
                fieldCondition: fieldConditionViewModel,
                groupCondition:GroupConditionViewModel()
            )
            
        } else if let groupCondition = conditionValue as? GroupCondition {
            groupConditionValue = groupCondition
            let groupConditionViewModel = GroupConditionViewModel.from(groupCondition)
            
            viewModel = ConditionDetailViewModel(
                conditionMode: .multiple,
                fieldCondition: FieldConditionViewModel(),
                groupCondition: groupConditionViewModel,
            )
            
        } else {
            fatalError("Unknown condition type: \(type(of: condition))")
        }
        
        let view = ConditionDetailView(window: window, viewModel: viewModel, onSave: { viewModel in
            
            switch viewModel.conditionMode {
                
            case .single:
                let fieldConditionViewModel = viewModel.fieldCondition
                if let fieldConditionValue = fieldConditionValue {
                    fieldConditionViewModel.to(fieldConditionValue)
                    onSave?(fieldConditionValue)
                    
                } else {
                    let fieldCondition = fieldConditionViewModel.to()
                    onSave?(fieldCondition)
                }
                
            case .multiple:
                let groupConditionViewModel = viewModel.groupCondition
                if let groupConditionValue = groupConditionValue {
                    groupConditionViewModel.to(groupConditionValue)
                    onSave?(groupConditionValue)
                    
                } else {
                    let groupCondition = groupConditionViewModel.to()
                    onSave?(groupCondition)
                }
            }
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
    ConditionDetailView(viewModel: ConditionDetailViewModel())
}
