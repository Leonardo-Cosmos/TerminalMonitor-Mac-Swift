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
            if let outputString = String(data: data, encoding: .utf8) {
                self.textPublisher.send(outputString)
            }
        }
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let outputString = String(data: data, encoding: .utf8) {
                self.textPublisher.send(outputString)
            }
        }
        
        process.terminationHandler = { process in
            
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            
            self.onCompleted()
        }
        
        try process.run()
        Self.logger.debug("Execution (id: \(self.id)) is started")
    }
    
    private func onCompleted(error: Error? = nil) {
        
        process = nil
        
        if let error = error {
            textPublisher.send(completion: .failure(error))
        } else {
            textPublisher.send(completion: .finished)
        }
        
        completed = true
    }
}
