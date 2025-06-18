//
//  BlockingQueue.swift
//  TerminalMonitor
//
//  Created on 2025/6/1.
//

import Foundation

actor BlockingQueue<Element> {
    
    private let asyncStream: AsyncStream<Element>
    
    private let continuation: AsyncStream<Element>.Continuation
    
    init() {
        (asyncStream, continuation) = AsyncStream<Element>.makeStream()
    }
    
    func yield(_ element: Element) {
        self.continuation.yield(element)
    }
    
    func finish() {
        self.continuation.finish()
    }
    
    func dequeue() async -> Element? {
        for await element in asyncStream {
            return element
        }
        return nil
    }
}
