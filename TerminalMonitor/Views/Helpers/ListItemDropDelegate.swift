//
//  ListItemDropDelegate.swift
//  TerminalMonitor
//
//  Created on 2025/5/29.
//

import SwiftUI

class ListItemDropDelegate<Item, ID>: DropDelegate where ID: Equatable {
    
    let item: Item
    
    let idKeyPath: KeyPath<Item, ID>
    
    let items: Binding<[Item]>
    
    init(item: Item, idKeyPath: KeyPath<Item, ID>, items: Binding<[Item]>) {
        self.item = item
        self.idKeyPath = idKeyPath
        self.items = items
    }
    
    func id(from provider: (any NSItemProviderReading)?) -> ID? {
        fatalError()
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }
        
        itemProvider.loadObject(ofClass: NSString.self) { object, error in
            if let sourceId = self.id(from: object) {
                let sourceIndex = self.items.wrappedValue.firstIndex(where: { $0[keyPath: self.idKeyPath] ==  sourceId })
                
                if let sourceIndex = sourceIndex {
                    let destinationIndex = self.items.wrappedValue.firstIndex {
                        $0[keyPath: self.idKeyPath] == self.item[keyPath: self.idKeyPath]
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
