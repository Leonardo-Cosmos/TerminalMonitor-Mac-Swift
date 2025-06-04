//
//  CommandExecutor.swift
//  TerminalMonitor
//
//  Created on 2025/5/24.
//

import Foundation
import Combine
import os

class CommandExecutor: Executor, TerminalLineProducer {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommandExecutor.self)
    )
    
    private struct ExecutionText {
        let text: String
        let executionName: String
    }
    
    static let shared = CommandExecutor()
    
    private var executorData = CommandExecutorData()
    
    private var executionTextBlockingQueue = BlockingQueue<ExecutionText>()
    
    private var terminalLineQueue = ConcurrentQueue<TerminalLine>()
    
    var executionStartedHandler: ExecutionInfoHandler?
    
    var executionExitedHandler: ExecutionInfoHandler?
    
    var startedHandler: ExecutorEventHandler?
    
    var completedHandler: ExecutorEventHandler?
    
    var commandFirstExecutionStartedHandler: CommandInfoHandler?
    
    var commandLastExecutionExitedHandler: CommandInfoHandler?
    
    private(set) var isCompleted = false
    
    private init() {
        Task(priority: .background) {
            await parseTerminalLine()
        }
    }
    
    func execute(commandConfig: CommandConfig) -> Task<Void, Never>? {
        
        Self.logger.info("Executing command (name: \(commandConfig.name), id: \(commandConfig.id))")
        
        let execution = Execution(commandConfig: commandConfig)
        
        let uniqueExecutionName = executorData.uniqueExecutionName(configName: commandConfig.name)
        let subscription = execution.textPublisher.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.removeExecution(executionId: execution.id)
            case .failure(let error):
                self.removeExecution(executionId: execution.id, error: error)
            }
            
            Self.logger.info("Execution (name: \(uniqueExecutionName), id: \(execution.id)) completed")
            
        }, receiveValue: { text in
            let executionText = ExecutionText(text: text, executionName: uniqueExecutionName)
            Task(priority: .background) {
                await self.executionTextBlockingQueue.yield(executionText)
            }
        })
        
        let added = addExecution(executionName: uniqueExecutionName, execution: execution, command: commandConfig, subscription: subscription)
        guard added else {
            return nil
        }
        
        return Task(priority: .userInitiated) {
            do {
                try execution.run()
                Self.logger.info("Execution (name: \(uniqueExecutionName), id: \(execution.id)) is started")
                
            } catch {
                Self.logger.error("Error when start execution \(uniqueExecutionName) \(execution.id). \(error)")
                removeExecution(executionId: execution.id, error: error)
            }
        }
    }
    
    func terminate(executionId: UUID) -> Task<Void, Never>? {
        
        guard let execution =  executorData.execution(executionId: executionId),
              let executionName =  executorData.executionName(executionId: executionId) else {
            Self.logger.error("Cannot find detail of execution (id: \(executionId))")
            return nil
        }
        
        Self.logger.info("Terminating execution (name: \(executionName), id: \(executionId))")
        
        return Task(priority: .userInitiated) {
            do {
                try execution.terminate()
            } catch {
                Self.logger.error("Error when terminate execution (name: \(executionName), id: \(executionId)). \(error)")
                removeExecution(executionId: executionId, error: error)
            }
        }
    }
    
    func restart(executionId: UUID) -> Task<Void, Never>? {
        
        guard let execution = executorData.execution(executionId: executionId) else {
            Self.logger.error("Cannot find detail of execution (id: \(executionId))")
            return nil
        }
        
        return Task {
            guard let terminateTask = terminate(executionId: executionId) else {
                return
            }
            
            await terminateTask.value
            await execute(commandConfig: execution.commandConfig)?.value
        }
    }
    
    func terminateAll(commandId: UUID) -> Task<Void, Never>? {
        
        guard let executionIds = executorData.executionIds(commandId: commandId) else {
            Self.logger.error("Cannot find execution set of command (id: \(commandId))")
            return nil
        }
        
        return Task {
            await withTaskGroup { taskGroup in
                
                for executionId in executionIds {
                    taskGroup.addTask {
                        await self.terminate(executionId: executionId)?.value
                    }
                }
                
                await taskGroup.waitForAll()
            }
        }
    }
    
    func terminateAll() -> Task<Void, Never> {
        
        let executionIds = executorData.executionIds()
        return Task {
            await withTaskGroup { taskGroup in
                
                for executionId in executionIds {
                    taskGroup.addTask {
                        await self.terminate(executionId: executionId)?.value
                    }
                }
                
                await taskGroup.waitForAll()
            }
        }
    }
    
    func shutdown() -> Task<Void, Never> {
        Task {
            await terminateAll().value
            await executionTextBlockingQueue.finish()
        }
    }
    
    func readTerminalLines() async -> [TerminalLine] {
        
        var terminalLines: [TerminalLine] = []
        while await !terminalLineQueue.isEmpty() {
            if let terminalLine = await terminalLineQueue.dequeue() {
                terminalLines.append(terminalLine)
            }
        }
        return terminalLines
    }
    
    private func addExecution(executionName: String, execution: Execution, command: CommandConfig, subscription: AnyCancellable) -> Bool {
        
        if executorData.isEmpty {
            onStarted()
        }
        
        if executorData.executionIds(commandId: command.id) == nil {
            onCommandFirstExecutionStarted(name: command.name, id: command.id)
        }
        
        do {
            try executorData.addExecution(executionName: executionName, execution: execution, subscription: subscription)
            
            onExecutionAdded(name: executionName, id: execution.id)
            
            return true
            
        } catch {
            Self.logger.error("Error when add execution (name: \(executionName), id: \(execution.id)). \(error)")
            return false
        }
    }
    
    @discardableResult
    private func removeExecution(executionId: UUID, error: Error? = nil) -> Bool {
        
        do {
            let (executionName, execution, subscription) = try executorData.removeExecution(executionId: executionId)
            
            subscription.cancel()
            
            onExecutionRemoved(name: executionName, id: executionId, error: error)
            
            let command = execution.commandConfig
            if executorData.executionIds(commandId: command.id) == nil {
                onCommandLastExecutionExited(name: command.name, id: command.id)
            }
            
        } catch {
            Self.logger.error("Error when remove execution (id: \(executionId)). \(error)")
            return false
        }
        
        if executorData.isEmpty {
            onCompleted()
        }
        
        return true
    }
    
    private func parseTerminalLine() async {
        
        while let executionText = await executionTextBlockingQueue.dequeue() {
            
            let terminalLine = TerminateLineParser.parseTerminalLine(
                text: executionText.text, execution: executionText.executionName)
            
            await terminalLineQueue.enqueue(terminalLine)
        }
    }
    
    private func onExecutionAdded(name: String, id: UUID) {
        
        let executionInfo = ExecutionInfo(
            id: id,
            name: name,
            status: .started
        )
        executionStartedHandler?(executionInfo, nil)
    }
    
    private func onExecutionRemoved(name: String, id: UUID, error: Error?) {
        let status: ExecutionStatus = error == nil ? .finished : .failed
        let executionInfo = ExecutionInfo(
            id: id,
            name: name,
            status: status
        )
        executionExitedHandler?(executionInfo, error)
    }
    
    private func onCommandFirstExecutionStarted(name: String, id: UUID) {
        
        let commandInfo = CommandInfo(
            id: id,
            name: name
        )
        commandFirstExecutionStartedHandler?(commandInfo)
    }
    
    private func onCommandLastExecutionExited(name: String, id: UUID) {
        
        let commandInfo = CommandInfo(
            id: id,
            name: name
        )
        commandLastExecutionExitedHandler?(commandInfo)
    }
    
    private func onStarted() {
        
        isCompleted = false
        startedHandler?()
    }
    
    private func onCompleted() {
        
        isCompleted = true
        completedHandler?()
    }
}
