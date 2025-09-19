//
//  SignalWaiter.swift
//  TerminalMonitor
//
//  Created on 2025/9/19.
//

import Foundation

class SignalWaiter {
    private var continuation: CheckedContinuation<Void, Never>?
    private var isSignaled = false
    
    func waitForSignal() async {
        if isSignaled {
            isSignaled = false
            return
        }
        
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    func sendSignal() {
        if let continuation = continuation {
            continuation.resume()
            self.continuation = nil
        } else {
            isSignaled = true
        }
    }
}
