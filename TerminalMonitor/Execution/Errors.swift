//
//  Errors.swift
//  TerminalMonitor
//
//  Created on 2025/5/26.
//

import Foundation

enum ExecutionError: Error {
    case alreadyStarted
    case notStarted
}

extension ExecutionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .alreadyStarted:
            return NSLocalizedString("It has been started already", comment: "Error when start an execution that has been started already")
        case .notStarted:
            return NSLocalizedString("It has not been started yet", comment: "Error when terminate an execution that has not been started yet")
        }
    }
}
