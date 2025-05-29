//
//  NotificationExtension.swift
//  TerminalMonitor
//
//  Created on 2025/5/28.
//

import Foundation

extension Notification.Name {
    
    static let commandStartingEvent = Notification.Name("commandStartingEvent")
    
    static let commandTerminatingEvent = Notification.Name("commandTerminatingEvent")
    
    static let executionTerminatingEvent = Notification.Name("executionTerminatingEvent")
    
    static let executionStartedEvent = Notification.Name("executionStartedEvent")
    
    static let executionExitedEvent = Notification.Name("executionExitedEvent")
}
