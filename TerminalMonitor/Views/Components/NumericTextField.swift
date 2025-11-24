//
//  NumericTextField.swift
//  TerminalMonitor
//
//  Created on 2025/11/13.
//

import SwiftUI

struct NumericTextField: View {
    
    private let numberPattern = try! Regex("\\d+")
    
    @Binding var value: Int
    
    var minValue: Int = 0
    
    var maxValue: Int = 100
    
    @State private var numberText: String = ""
    
    var body: some View {
        TextField("", text: $numberText)
            .onChange(of: numberText) {
                if isValidText(text: numberText) {
                    value = Int(numberText)!
                } else {
                    numberText = validText(text: numberText) ?? value.description
                }
            }
            .onAppear() {
                numberText = value.description
            }
    }
    
    private func isValidText(text: String) -> Bool {
        if try! numberPattern.wholeMatch(in: text) == nil {
            return false
        }
        return isValidNumber(number: Int(text)!)
    }
    
    private func isValidNumber(number: Int) -> Bool {
        return number <= maxValue && number >= minValue
    }
    
    private func validText(text: String) -> String? {
        if try! numberPattern.wholeMatch(in: text) == nil {
            return nil
        }
        
        let number = Int(text)!
        if number > maxValue {
            return maxValue.description
        } else if number < minValue {
            return minValue.description
        } else {
            return nil
        }
    }
}

#Preview {
    NumericTextField(
        value: Binding.constant(0), minValue: -10, maxValue: 10)
}
