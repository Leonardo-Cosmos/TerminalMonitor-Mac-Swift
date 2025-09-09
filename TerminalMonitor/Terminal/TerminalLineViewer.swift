//
//  TerminalLinesViewer.swift
//  TerminalMonitor
//
//  Created on 2025/6/25.
//

import Foundation

protocol TerminalLineViewer {
    
    func removeTerminalLinesUtil(terminalLineId: UUID)
    
    func removeTerminalLinesUntilLast()
    
    var terminalLines: [TerminalLine] { get }
}
