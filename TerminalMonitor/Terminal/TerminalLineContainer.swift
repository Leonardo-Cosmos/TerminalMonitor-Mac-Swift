//
//  TerminalLineContainer.swift
//  TerminalMonitor
//
//  Created on 2025/6/20.
//

import Foundation

protocol TerminalLineContainer {
    
    typealias TerminalLinesHandler = ([TerminalLine]) -> Void
    
    func appendTerminalLines(terminalLines: [TerminalLine])
    
    var terminalLinesAppendedHandler: TerminalLinesHandler? { get set }
    
    var terminalLinesRemovedHandler: TerminalLinesHandler? { get set }
}
