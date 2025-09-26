//
//  CommandExecutorData.swift
//  TerminalMonitor
//
//  Created on 2025/6/3.
//

import Foundation
import Combine
import os

struct CommandExecutorData {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Self.self)
    )
    
    private let executionLock = NSRecursiveLock()
    
    /**
     A set of names of running executions.
     */
    private var executionNames: Set<String> = []
    
    /**
     A dictionary from execution ID to execution name.
     */
    private var executionNameDict: [UUID: String] = [:]
    
    /**
     A dictionary from execution ID to execution detail.
     */
    private var executionDict: [UUID: Execution] = [:]
    
    /**
     A dictionary from command ID to execution ID set.
     */
    private var commandExecutionsDict: [UUID: Set<UUID>] = [:]
    
    /**
     A dictionary from execution ID to subscription of execution output.
     */
    private var subscriptionDict: [UUID: AnyCancellable] = [:]
    
    var isEmpty: Bool {
        get {
            executionLock.lock()
            defer {
                executionLock.unlock()
            }
            
            return executionNames.isEmpty
        }
    }
    
    mutating func addExecution(executionName: String, execution: Execution, subscription: AnyCancellable) throws {
        
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        
        guard !executionNames.contains(executionName) else {
            throw ExecutorError.duplicatedName(name: executionName)
        }
        
        guard !executionDict.keys.contains(where: { $0 == execution.id }) else {
            throw ExecutorError.duplicatedId(id: execution.id)
        }
        
        executionNames.insert(executionName)
        executionNameDict[execution.id] = executionName
        executionDict[execution.id] = execution
        
        let commandConfig = execution.commandConfig
        var commandExecutions = commandExecutionsDict[commandConfig.id]
        if var commandExecutions = commandExecutions {
            commandExecutions.insert(execution.id)
            commandExecutionsDict[commandConfig.id] = commandExecutions
        } else {
            commandExecutions = [execution.id]
            commandExecutionsDict[commandConfig.id] = commandExecutions
        }
        
        subscriptionDict[execution.id] = subscription
    }
    
    mutating func removeExecution(executionId: UUID) throws -> (String, Execution, AnyCancellable) {
        
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        
        
        let executionName = executionNameDict.removeValue(forKey: executionId)
        guard let executionName = executionName else {
            throw ExecutorError.notExistId(id: executionId)
        }
        
        executionNames.remove(executionName)
        
        let exectuion = executionDict.removeValue(forKey: executionId)!
        
        let commandConfig = exectuion.commandConfig
        
        var commandExecutions = commandExecutionsDict[commandConfig.id]!
        commandExecutions.remove(executionId)
        if commandExecutions.isEmpty {
            commandExecutionsDict.removeValue(forKey: commandConfig.id)
        } else {
            commandExecutionsDict[commandConfig.id] = commandExecutions
        }
        
        let subscription = subscriptionDict.removeValue(forKey: executionId)!
        
        return (executionName, exectuion, subscription)
        
    }
    
    func execution(executionId: UUID) -> Execution? {
        
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        
        return executionDict[executionId]
    }
    
    func executionName(executionId: UUID) -> String? {
        
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        
        return executionNameDict[executionId]
    }
    
    func executionIds() -> Set<UUID> {
        
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        
        return Set(executionDict.keys)
    }
    
    func executionIds(commandId: UUID) -> Set<UUID>? {
        
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        
        return commandExecutionsDict[commandId]
    }
    
    /**
     By default, the execution takes command's name,
     but when there are multiple execution from same command,
     each execution should have a unique name.
     */
    func uniqueExecutionName(configName: String) -> String {
        
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        
        if !executionNames.contains(configName) {
            return configName
        }
        
        var number = 0
        var name: String
        repeat {
            number = number + 1
            name = "\(configName) \(number)"
        } while executionNames.contains(name)
        
        return name
    }
}
