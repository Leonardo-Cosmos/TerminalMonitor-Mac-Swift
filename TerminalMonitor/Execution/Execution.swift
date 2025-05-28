//
//  Execution.swift
//  TerminalMonitor
//
//  Created on 2025/5/24.
//

import Foundation
import Combine

class Execution {
    
    let id: UUID
    
    private let commandConfig: CommandConfig
    
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
                             currentDirPath: self.commandConfig.currentDirectory) {
                    self.startLock.unlock()
                }
                process = nil
                
                self.textPublisher.send(completion: .finished)
                self.completed = true
                
            } catch {
                process = nil
                
                self.textPublisher.send(completion: .failure(error))
                self.completed = true
            }
        }
    }
    
    func terminate() throws {
        startLock.lock()
        if !started {
            startLock.unlock()
            throw ExecutionError.notStarted
        }
        startLock.unlock()
        
        process?.terminate()
    }
    
    private func run(executableFilePath: String?, arguments: String?, currentDirPath: String?, onStarted: () -> Void) throws {
        
        guard let executableFilePath = executableFilePath else {
            return
        }
        
        process = Process()
        
        guard let process = process else {
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
                print("From process: \(outputString)")
                self.textPublisher.send(outputString)
            }
        }
        
        defer {
            outputPipe.fileHandleForReading.readabilityHandler = nil
        }
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let outputString = String(data: data, encoding: .utf8) {
                print("From process: \(outputString)")
                self.textPublisher.send(outputString)
            }
        }
        
        defer {
            outputPipe.fileHandleForReading.readabilityHandler = nil
        }
        
        try process.run()
        onStarted()
        process.waitUntilExit()
    }
}
