//
//  TextStyleConditionView.swift
//  TerminalMonitor
//
//  Created on 2025/11/17.
//

import SwiftUI
import Combine

struct TextStyleConditionView: View {
    
    @ObservedObject var viewModel: TextStyleConditionViewModel
    
    var body: some View {
        VStack {
            GroupBox(label: EmptyView()) {
                HStack {
                    Toggle("Inherit default", isOn: $viewModel.inheritDefault)
                        .padding(.trailing)
                    
                    Button("Edit", systemImage: "pencil") {
                        ConditionDetailWindowController.openWindow(for: $viewModel.condition) { condition in
                            viewModel.condition = condition
                        }
                    }
                    .labelStyle(.iconOnly)
                    
                    Text("Condition")
                    
                    Text(viewModel.condition.conditionDescription)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(1)))
                    
                    HStack {
                        
                        SymbolButtonToggle(
                            toggle: Binding(
                                get: { viewModel.condition.isInverted },
                                set: { viewModel.condition.isInverted = $0 }
                            ),
                            toggleOnSystemImage: "minus.circle.fill",
                            toggleOnSystemColor: .red,
                            toggleOnHelpTextKey: NSLocalizedString("Matching is Inverted", comment: ""),
                            toggleOffSystemImage: "largecircle.fill.circle",
                            toggleOffSystemColor: .green,
                            toggleOffHelpTextKey: NSLocalizedString("Matching is not Inverted", comment: "")
                        )
                        
                        SymbolButtonToggle(
                            toggle: Binding(
                                get: { viewModel.condition.defaultResult },
                                set: { viewModel.condition.defaultResult = $0 }
                            ),
                            toggleOnSystemImage: "star.fill",
                            toggleOnSystemColor: .yellow,
                            toggleOnHelpTextKey: NSLocalizedString("Default to True when the Field is not Found", comment: ""),
                            toggleOffSystemImage: "star",
                            toggleOffSystemColor: .yellow,
                            toggleOffHelpTextKey: NSLocalizedString("Default to False when the Field is not Found", comment: "")
                        )
                        
                        SymbolButtonToggle(
                            toggle: Binding(
                                get: { viewModel.condition.isDisabled },
                                set: { viewModel.condition.isDisabled = $0 }
                            ),
                            toggleOnSystemImage: "pause.circle",
                            toggleOnSystemColor: .red,
                            toggleOnHelpTextKey: NSLocalizedString("This Condition is Disabled", comment: ""),
                            toggleOffSystemImage: "dot.circle",
                            toggleOffSystemColor: .green,
                            toggleOffHelpTextKey: NSLocalizedString("This Condition is Enabled", comment: "")
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                TextStyleView(viewModel: viewModel.style)
            }
        }
    }
}

class TextStyleConditionViewModel: Identifiable, ObservableObject {
    
    let id: UUID
    
    @Published var style: TextStyleViewModel
    
    @Published var inheritDefault: Bool
    
    @Published var condition: Condition
    
    private var cancellables = Set<AnyCancellable>()
    
    init(id: UUID, style: TextStyleViewModel, inheritDefault: Bool, condition: Condition) {
        self.id = id
        self.style = style
        self.inheritDefault = inheritDefault
        self.condition = condition
        
        condition.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    convenience init(style: TextStyleViewModel, inheritDefault: Bool, condition: Condition) {
        self.init(
            id: UUID(),
            style: style,
            inheritDefault: inheritDefault,
            condition: condition,
        )
    }
    
    convenience init(condition: Condition) {
        self.init(
            style: TextStyleViewModel(),
            inheritDefault: false,
            condition: condition,
        )
    }
    
    func to(_ textStyleCondition: TextStyleCondition) {
        style.to(textStyleCondition.style)
        textStyleCondition.inheritDefault = inheritDefault
        textStyleCondition.condition = condition
    }
    
    func to() -> TextStyleCondition {
        TextStyleCondition(
            style: style.to(),
            inheritDefault: inheritDefault,
            condition: condition,
        )
    }
    
    static func from(_ textStyleCondition: TextStyleCondition) -> TextStyleConditionViewModel {
        TextStyleConditionViewModel(
            style: TextStyleViewModel.from(textStyleCondition.style),
            inheritDefault: textStyleCondition.inheritDefault,
            condition: textStyleCondition.condition,
        )
    }
}

#Preview {
    TextStyleConditionView(viewModel: TextStyleConditionViewModel(
        condition: FieldCondition(fieldKey: "plaintext", matchOperator: .equals, targetValue: "{}")
    ))
}
