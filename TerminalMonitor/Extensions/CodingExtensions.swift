//
//  CodingExtensions.swift
//  TerminalMonitor
//
//  Created on 2026/1/3.
//

import Foundation

extension KeyedDecodingContainer {
    
    func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key, using factory: (Decoder) throws -> T) throws -> T {
        let nested = try self.superDecoder(forKey: key)
        return try factory(nested)
    }
    
    func decode<T>(_ type: [T].Type, forKey key: KeyedDecodingContainer<K>.Key, using factory: (Decoder) throws -> T) throws -> [T] {
        var array = [T]()
        var nested = try self.nestedUnkeyedContainer(forKey: key)
        while !nested.isAtEnd {
            let decoder = try nested.superDecoder()
            array.append(try factory(decoder))
        }
        return array
    }
}

extension KeyedEncodingContainer {
    
    mutating func encode(_ item: ConditionSetting, forKey key: KeyedEncodingContainer<K>.Key, using encode: (ConditionSetting, Encoder) throws -> Void) throws {
        let nested = self.superEncoder(forKey: key)
        try item.encode(to: nested)
    }
    
    mutating func encode(_ array: [ConditionSetting], forKey key: KeyedEncodingContainer<K>.Key, using encode: (ConditionSetting, Encoder) throws -> Void) throws {
        var nested = self.nestedUnkeyedContainer(forKey: key)
        for node in array {
            let encoder = nested.superEncoder()
            try encode(node, encoder)
        }
    }
}
