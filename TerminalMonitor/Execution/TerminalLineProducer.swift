//
//  TerminalLine.swift
//  TerminalMonitor
//
//  Created on 2025/5/27.
//

import Foundation

protocol TerminalLineProducer {
    
    typealias ExecutorEventHandler = () -> Void
    
    func readTerminalLines() async -> [TerminalLine]
    
    var startedHandler: ExecutorEventHandler? { get set }
    
    var completedHandler: ExecutorEventHandler? { get set }
    
    var isCompleted: Bool { get }
}
