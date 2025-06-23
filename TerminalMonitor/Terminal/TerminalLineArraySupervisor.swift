//
//  TerminalLineArraySupervisor.swift
//  TerminalMonitor
//
//  Created on 6/20/25.
//

import Foundation

class TerminalLineArraySupervisor: TerminalSupervisor {
    
    static let shared = TerminalLineArraySupervisor()
    
    var terminalLines: [TerminalLine] = []
    
    var terminalLinesAppendedHandler: TerminalLinesHandler?
    
    var terminalLinesRemovedHandler: TerminalLinesHandler?
    
    func appendTerminalLines(terminalLines: [TerminalLine]) {
        self.terminalLines.append(contentsOf: terminalLines)
        
        onTerminalLinesAppended(terminalLines: terminalLines)
    }
    
    func removeTerminalLinesUtil(terminalLineId: UUID) {
        guard let index = terminalLines.firstIndex(where: { $0.id == terminalLineId }) else {
            return
        }
        
        let removedTerminalLines = Array(terminalLines[0...index])
        terminalLines = Array(terminalLines[(index + 1)...])
        
        onTerminalLinesRemoved(terminalLines: removedTerminalLines)
    }
    
    private func onTerminalLinesAppended(terminalLines: [TerminalLine]) {
        
        terminalLinesAppendedHandler?(terminalLines)
    }
    
    private func onTerminalLinesRemoved(terminalLines: [TerminalLine]) {
        
        terminalLinesRemovedHandler?(terminalLines)
    }
}
