//
//  TerminateLineParser.swift
//  TerminalMonitor
//
//  Created by Leximus on 5/28/25.
//

import Foundation

class TerminateLineParser {
    
    private static let keySeparator = "."
    
    static func parseTerminalLine(text: String, execution: String) -> TerminalLine {
        
        let id = UUID()
        let timestamp = Date()
        
        let systemFieldDict: [String: Any] = [
            "id": id,
            "timestamp": timestamp,
            "plaintext": text,
            "execution": execution,
        ]
        
        var lineFieldDict: [String: TerminalLineField] = [:]
        mergeTerminateLineDict(unionDict: &lineFieldDict, partialDict: systemFieldDict, keyPrefix: "system")
        
        return TerminalLine(
            id: id,
            timestamp: timestamp,
            plaintext: text,
            lineFieldDict: lineFieldDict
        )
    }
    
    private static func mergeTerminateLineDict(unionDict: inout [String: TerminalLineField],
                                               partialDict: [String: Any], keyPrefix: String) {
        
        for (key, value) in partialDict {
            let mergedFieldKey = "\(keyPrefix)\(keySeparator)\(key)"
            unionDict[mergedFieldKey] = TerminalLineField(
                key: key,
                fieldKey: mergedFieldKey,
                value: value,
                text: describeValue(value)
            )
        }
    }
    
    private static func describeValue(_ value: Any?) -> String {
        guard let value = value else {
            return "%null%"
        }
        return "\(value)"
    }
}
