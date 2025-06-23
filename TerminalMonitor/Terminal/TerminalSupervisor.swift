//
//  TerminalLinesSupervisor.swift
//  TerminalMonitor
//
//  Created on 2025/6/20.
//

import Foundation

protocol TerminalSupervisor {
    
    typealias TerminalLinesHandler = ([TerminalLine]) -> Void
    
    func appendTerminalLines(terminalLines: [TerminalLine])
    
    func removeTerminalLinesUtil(terminalLineId: UUID)
    
    var terminalLines: [TerminalLine] { get }
    
    var terminalLinesAppendedHandler: TerminalLinesHandler? { get set }
    
    var terminalLinesRemovedHandler: TerminalLinesHandler? { get set }
}
