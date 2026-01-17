//
//  ExecutionInfo.swift
//  TerminalMonitor
//
//  Created on 2025/5/26.
//

import Foundation

struct ExecutionInfo {
    
    let id: UUID
    
    let name: String
    
    let status: ExecutionStatus
}

func previewExecutionInfo() -> [ExecutionInfo] {
    [
        ExecutionInfo(id: UUID(), name: "Console", status: .started),
        ExecutionInfo(id: UUID(), name: "Application", status: .started),
        ExecutionInfo(id: UUID(), name: "Tool", status: .started),
    ]
}
