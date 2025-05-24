//
//  ContentView.swift
//  TerminalMonitor
//
//  Created on 2025/5/8.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @ObservedObject var appViewModel: AppViewModel
    
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            CommandListView(appViewModel: appViewModel)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            Text("Select an item")
        }
    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView(appViewModel: AppViewModel())
        .modelContainer(for: Item.self, inMemory: true)
}
