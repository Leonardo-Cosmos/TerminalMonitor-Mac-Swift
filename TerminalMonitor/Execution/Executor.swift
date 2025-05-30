//
//  Executor.swift
//  TerminalMonitor
//
//  Created on 2025/5/29.
//

import Foundation

protocol Executor {
    
    typealias ExecutionInfoHandler = (ExecutionInfo, Error?) -> Void
    
    func execute(commandConfig: CommandConfig)
    
    func terminate(executionId: UUID)
    
    func terminateAll()
    
    func shutdown()
    
    var executionStartedHandler: ExecutionInfoHandler? { get set }
    
    var executionExitedHandler: ExecutionInfoHandler? { get set }
}
