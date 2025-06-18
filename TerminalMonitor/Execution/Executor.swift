//
//  Executor.swift
//  TerminalMonitor
//
//  Created on 2025/5/29.
//

import Foundation

protocol Executor {
    
    typealias ExecutionInfoHandler = (ExecutionInfo, Error?) -> Void
    
    typealias CommandInfoHandler = (CommandInfo) -> Void
    
    @discardableResult
    func execute(commandConfig: CommandConfig) -> Task<Void, Never>
    
    @discardableResult
    func terminate(executionId: UUID) -> Task<Void, Never>
    
    @discardableResult
    func restart(executionId: UUID) -> Task<Void, Never>
    
    @discardableResult
    func terminateAll(executionIds: Set<UUID>) -> Task<Void, Never>
    
    @discardableResult
    func terminateAll(commandId: UUID) -> Task<Void, Never>
    
    @discardableResult
    func terminateAll() -> Task<Void, Never>
    
    @discardableResult
    func shutdown() -> Task<Void, Never>
    
    var executionStartedHandler: ExecutionInfoHandler? { get set }
    
    var executionExitedHandler: ExecutionInfoHandler? { get set }
    
    var commandFirstExecutionStartedHandler: CommandInfoHandler? { get set }
    
    var commandLastExecutionExitedHandler: CommandInfoHandler? { get set }
}
