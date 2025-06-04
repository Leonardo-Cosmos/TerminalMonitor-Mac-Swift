//
//  NotificationExtension.swift
//  TerminalMonitor
//
//  Created on 2025/5/28.
//

import Foundation

extension Notification.Name {
    
    static let commandToStartEvent = Notification.Name("commandToStartEvent")
    
    static let commandToStopEvent = Notification.Name("commandToStopEvent")
    
    static let commandFirstExecutionStartedEvent = Notification.Name("commandFirstExecutionStartedEvent")
    
    static let commandLastExecutionExitedEvent = Notification.Name("commandLastExecutionExitedEvent")
    
    static let executionToStopEvent = Notification.Name("executionToStopEvent")
    
    static let executionToRestartEvent = Notification.Name("executionToRestartEvent")
    
    static let executionStartedEvent = Notification.Name("executionStartedEvent")
    
    static let executionExitedEvent = Notification.Name("executionExitedEvent")
}
