//
//  ConcurrentQueue.swift
//  TerminalMonitor
//
//  Created on 2025/5/27.
//

import Foundation

actor ConcurrentQueue<Element> {
    
    private var queue: [Element] = []
    
    func enqueue(_ element: Element) {
        queue.append(element)
    }
    
    func dequeue() -> Element? {
        guard !queue.isEmpty else {
            return nil
        }
        return queue.removeFirst()
    }
    
    func isEmpty() -> Bool {
        return queue.isEmpty
    }
}
