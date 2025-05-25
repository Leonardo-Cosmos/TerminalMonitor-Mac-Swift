//
//  Execution.swift
//  TerminalMonitor
//
//  Created on 2025/5/24.
//

import Foundation

class Execution {
    
    let id: UUID
    
    private let commandConfig: CommandConfig
    
    private var started = false
    
    private var process: Process?
    
    private var processTask: Task<Void, Error>?
    
    init(commandConfig: CommandConfig) {
        self.id = UUID()
        self.commandConfig = commandConfig
    }
    
    private func start(executableFilePath: String?, arguments: String?, currentDirPath: String?) {
        
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
                print(outputString)
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
                print(outputString)
            }
        }
        
        defer {
            outputPipe.fileHandleForReading.readabilityHandler = nil
        }
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Error running process: \(error)")
        }
        
    }
    
}
