//
//  Execution.swift
//  TerminalMonitor
//
//  Created on 2025/5/24.
//

import Foundation
import Combine
import os

class Execution {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Execution.self)
    )
    
    let id: UUID
    
    let commandConfig: CommandConfig
    
    private var started = false
    
    private let startSemaphore = DispatchSemaphore(value: 1)
    
    private let terminationWaiter = SignalWaiter()
    
    private(set) var completed = false
    
    private var process: Process?
    
    let textPublisher = PassthroughSubject<String, Error>()
    
    init(commandConfig: CommandConfig) {
        self.id = UUID()
        self.commandConfig = commandConfig
    }
    
    @discardableResult
    func run() throws -> Task<Void, Never> {
        
        Self.logger.debug("Execution (id: \(self.id)) is starting")
        
        startSemaphore.wait()
        if started {
            startSemaphore.signal()
            throw ExecutionError.alreadyStarted
        }
        
        started = true
        
        return Task {
            defer {
                startSemaphore.signal()
            }
            
            do {
                try self.run(executableFilePath: self.commandConfig.executableFile,
                             arguments: self.commandConfig.arguments,
                             currentDirPath: self.commandConfig.currentDirectory)
                
                Self.logger.debug("Execution (id: \(self.id)) is started")
                
            } catch {
                onCompleted(error: error)
            }
        }
    }
    
    @discardableResult
    func terminate() throws -> Task<Void, Never> {
        
        Self.logger.debug("Execution (id: \(self.id)) is terminating")
        
        startSemaphore.wait()
        if !started {
            startSemaphore.signal()
            throw ExecutionError.notStarted
        }
        startSemaphore.signal()
        
        return Task {
            process?.terminate()
            await terminationWaiter.waitForSignal()
            Self.logger.info("Execution (id: \(self.id)) is terminated")
        }
    }
    
    private func run(executableFilePath: String?, arguments: String?, currentDirPath: String?) throws {
        
        guard let executableFilePath = executableFilePath else {
            onCompleted()
            return
        }
        
        process = Process()
        
        guard let process = process else {
            onCompleted()
            return
        }
        
        process.executableURL = URL(filePath: executableFilePath, directoryHint: .notDirectory)
        
        if let arguments = arguments {
            process.arguments = arguments
                .split(separator: " ", omittingEmptySubsequences: true)
                .map { String($0) }
        }
        
        if let currentDirPath = currentDirPath {
            process.currentDirectoryURL = URL(filePath: currentDirPath, directoryHint: .isDirectory)
        }
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            self.publishProcessOutput(data: data)
        }
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            self.publishProcessOutput(data: data)
        }
        
        process.terminationHandler = { process in
            
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            
            self.onCompleted()
        }
        
        try process.run()
    }
    
    private func publishProcessOutput(data: Data) {
        guard !data.isEmpty else {
            return
        }
        
        if var outputString = String(data: data, encoding: .utf8) {
            // Normally, the process output is received with the line feed character at end.
            if outputString.last == "\n" {
                outputString.removeLast()
            }
            
            // The output might contains multiple lines with line feed characters.
            if outputString.contains("\n") {
                let lines = outputString.split(separator: "\n", omittingEmptySubsequences: false)
                for line in lines {
                    self.textPublisher.send(String(line))
                }
            } else {
                self.textPublisher.send(outputString)
            }
        }
    }
    
    private func onCompleted(error: Error? = nil) {
        
        process = nil
        
        if let error = error {
            textPublisher.send(completion: .failure(error))
        } else {
            textPublisher.send(completion: .finished)
        }
        
        terminationWaiter.sendSignal()
        completed = true
    }
}
