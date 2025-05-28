//
//  CommandExecutor.swift
//  TerminalMonitor
//
//  Created on 2025/5/24.
//

import Foundation
import Combine
import os

class CommandExecutor {
    
    typealias ExecutionInfoHandler = (ExecutionInfo, Error?) -> Void
    
    typealias ExecutorEventHandler = () -> Void
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommandExecutor.self)
    )
    
    private struct ExecutionText {
        let text: String
        let executionName: String
    }
    
    private var executionNames: Set<String> = []
    
    private var executionNameDict: [UUID: String] = [:]
    
    private var executionDict: [UUID: Execution] = [:]
    
    private var subscriptionDict: [UUID: AnyCancellable] = [:]
    
    private var executionTextAsyncStream: AsyncStream<ExecutionText>
    
    private var executionTextContinuation: AsyncStream<ExecutionText>.Continuation
    
    private var terminalLineQueue = ConcurrentQueue<TerminalLine>()
    
    var executionStartedHandler: ExecutionInfoHandler?
    
    var executionExitedHandler: ExecutionInfoHandler?
    
    var startedHandler: ExecutorEventHandler?
    
    var completedHandler: ExecutorEventHandler?
    
    private(set) var isCompleted = false
    
    init() {
        (executionTextAsyncStream, executionTextContinuation) = AsyncStream<ExecutionText>.makeStream()
        Task {
            await parseTerminalLine()
        }
    }
    
    func execute(commandConfig: CommandConfig) {
        
        let execution = Execution(commandConfig: commandConfig)
        let uniqueExecutionName = uniqueExecutionName(configName: commandConfig.name)
        
        let subscription = execution.textPublisher.sink(receiveCompletion: { completion in
            
            switch completion {
            case .finished:
                self.removeExecution(name: uniqueExecutionName, id: execution.id)
            case .failure(let error):
                self.removeExecution(name: uniqueExecutionName, id: execution.id, error: error)
            }
            
            Self.logger.info("Execution \(uniqueExecutionName) \(execution.id) is started")
            
        }, receiveValue: { text in
            
            let executionText = ExecutionText(text: text, executionName: uniqueExecutionName)
            Task {
                self.executionTextContinuation.yield(executionText)
            }
        })
        
        subscriptionDict[execution.id] = subscription
        addExecution(name: uniqueExecutionName, execution: execution)
        
        Self.logger.info("Execution \(uniqueExecutionName) \(execution.id) is started")
        Task {
            do {
                try execution.run()
            } catch {
                Self.logger.error("Error when start execution \(uniqueExecutionName) \(execution.id). \(error)")
                removeExecution(name: uniqueExecutionName, id: execution.id, error: error)
            }
        }
    }
    
    func terminate(executionId: UUID) {
        
        guard let execution = executionDict[executionId] else {
            Self.logger.log("Execution \(executionId) doesn't exist when terminate it")
            return
        }
        
        let executionName = executionNameDict[executionId]!
        
        Task {
            do {
                try execution.terminate()
            } catch {
                Self.logger.error("Error when terminate execution \(executionName) \(executionId). \(error)")
                removeExecution(name: executionName, id: executionId, error: error)
            }
        }
    }
    
    func terminateAll() {
        for executionId in executionDict.keys {
            terminate(executionId: executionId)
        }
    }
    
    func shutdown() {
        terminateAll()
        executionTextContinuation.finish()
    }
    
    private func addExecution(name: String, execution: Execution) {
        
        if executionNames.isEmpty {
            onStarted()
        }
        
        let executionId = execution.id
        executionNames.insert(name)
        executionNameDict[executionId] = name
        executionDict[executionId] = execution
        
        onExecutionAdded(name: name, id: executionId)
    }
    
    private func removeExecution(name: String, id: UUID, error: Error? = nil) {
        
        executionNames.remove(name)
        executionNameDict[id] = nil
        executionDict[id] = nil
        
        onExecutionRemoved(name: name, id: id, error: error)
        
        if executionNames.isEmpty {
            onCompleted()
        }
    }
    
    /**
     By default, the execution takes command's name,
     but when there are multiple execution from same command,
     each execution should have a unique name.
     */
    private func uniqueExecutionName(configName: String) -> String {
        
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
    
    private func parseTerminalLine() async {
        
        for await executionText in executionTextAsyncStream {
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
            status: .started
        )
        executionExitedHandler?(executionInfo, error)
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
