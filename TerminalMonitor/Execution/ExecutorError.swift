//
//  ExecutorError.swift
//  TerminalMonitor
//
//  Created on 2025/6/3.
//

import Foundation

enum ExecutorError: Error {
    
    case duplicatedName(name: String)
    
    case duplicatedId(id: UUID)
    
    case notExistId(id: UUID)
}
