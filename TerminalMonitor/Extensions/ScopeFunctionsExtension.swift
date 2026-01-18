//
//  ScopeFunctionsExtension.swift
//  TerminalMonitor
//
//  Created on 2026/1/18.
//

import Foundation

protocol ScopeFunctions {}

extension ScopeFunctions {
    
    func run<T>(_ block: (Self) throws -> T) rethrows -> T {
        return try block(self)
    }
}

extension TextColorConfig: ScopeFunctions {}
