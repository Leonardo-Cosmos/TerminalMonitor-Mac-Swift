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
    
    var onSave: (() -> Void)?
    
    var body: some View {
        VStack {
            
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

class GroupConditionViewModel: ObservableObject {
    
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
        if let fieldCondition = conditionValue as? FieldCondition {
            let fieldConditionViewModel = FieldConditionViewModel(
                fieldKey: fieldCondition.fieldKey,
                matchOperator: fieldCondition.matchOperator,
                targetValue: fieldCondition.targetValue,
                isInverted: fieldCondition.isInverted,
                defaultResult: fieldCondition.defaultResult,
                isDisabled: fieldCondition.isDisabled,
            )
            
            viewModel = ConditionDetailViewModel(
                conditionMode: .single,
                fieldCondition: fieldConditionViewModel,
                groupCondition:GroupConditionViewModel()
            )
            
        } else if let groupCondition = conditionValue as? GroupCondition {
            viewModel = ConditionDetailViewModel(
                conditionMode: .multiple,
                fieldCondition: FieldConditionViewModel(),
                groupCondition: GroupConditionViewModel(),
            )
            
        } else {
            fatalError("Unknown condition type")
        }
        
        let view = ConditionDetailView(window: window, viewModel: viewModel)
        
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
