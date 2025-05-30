//
//  ListItemDropDelegate.swift
//  TerminalMonitor
//
//  Created on 2025/5/29.
//

import SwiftUI

class ListItemDropDelegate<Item, ID>: DropDelegate where ID: Equatable {
    
    let id: KeyPath<Item, ID>
    
    let item: Item
    
    let items: Binding<[Item]>
    
    let providerHandler: ((any NSItemProviderReading)?) -> ID?
    
    init(id: KeyPath<Item, ID>, item: Item, items: Binding<[Item]>, providerHandler: @escaping ((any NSItemProviderReading)?) -> ID?) {
        self.id = id
        self.item = item
        self.items = items
        self.providerHandler = providerHandler
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }
        
        itemProvider.loadObject(ofClass: NSString.self) { object, error in
            if let sourceId = self.providerHandler(object) {
                let sourceIndex = self.items.wrappedValue.firstIndex(where: { $0[keyPath: self.id] ==  sourceId })
                
                if let sourceIndex = sourceIndex {
                    let destinationIndex = self.items.wrappedValue.firstIndex {
                        $0[keyPath: self.id] == self.item[keyPath: self.id]
                    }
                    
                    if let destinationIndex = destinationIndex {
                        Task { @MainActor in
                            let movedItem = self.items.wrappedValue.remove(at: sourceIndex)
                            self.items.wrappedValue.insert(movedItem, at: destinationIndex)
                        }
                    }
                }
            }
        }
        
        return true
    }
    
}
