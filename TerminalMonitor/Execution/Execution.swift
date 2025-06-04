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
    
    private let startLock = NSLock()
    
    private(set) var completed = false
    
    private var process: Process?
    
    let textPublisher = PassthroughSubject<String, Error>()
    
    init(commandConfig: CommandConfig) {
        self.id = UUID()
        self.commandConfig = commandConfig
    }
    
    func run() throws {
        
        Self.logger.debug("Execution (id: \(self.id)) is started")
        
        startLock.lock()
        if started {
            startLock.unlock()
            throw ExecutionError.alreadyStarted
        }
        
        started = true
        
        Task {
            do {
                try self.run(executableFilePath: self.commandConfig.executableFile,
                             arguments: self.commandConfig.arguments,
                             currentDirPath: self.commandConfig.currentDirectory,
                             startLock: self.startLock)
            } catch {
                onCompleted(error: error)
            }
        }
    }
    
    func terminate() throws {
        
        Self.logger.debug("Execution (id: \(self.id)) is terminated")
        
        startLock.lock()
        if !started {
            startLock.unlock()
            throw ExecutionError.notStarted
        }
        startLock.unlock()
        
        process?.terminate()
    }
    
    private func run(executableFilePath: String?, arguments: String?, currentDirPath: String?, startLock: NSLock) throws {
        
        defer {
            startLock.unlock()
        }
        
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
        Self.logger.debug("Execution \(self.id) is running")
        
        // process.waitUntilExit()
    }
    
    private func onCompleted(error: Error? = nil) {
        
        process = nil
        
        if let error = error {
            textPublisher.send(completion: .failure(error))
        } else {
            textPublisher.send(completion: .finished)
        }
        
        self.completed = true
    }
}
