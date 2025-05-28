//
//  ConcurrentQueue.swift
//  TerminalMonitor
//
//  Created on 2025/5/27.
//

import Foundation

actor ConcurrentQueue<T> {
    
    private var queue: [T] = []
    
    func enqueue(_ element: T) {
        queue.append(element)
    }
    
    func dequeue() -> T? {
        guard !queue.isEmpty else {
            return nil
        }
        return queue.removeFirst()
    }
    
    func isEmpty() -> Bool {
        return queue.isEmpty
    }
}
