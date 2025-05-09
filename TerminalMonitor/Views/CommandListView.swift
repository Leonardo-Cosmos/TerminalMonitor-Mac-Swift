//
//  CommandListView.swift
//  TerminalMonitor
//
//  Created on 2025/5/9.
//

import SwiftUI

struct CommandListView: View {
    
    @StateObject private var viewModel = CommandViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.commands) { command in
                VStack {
                    Text(command.name)
                        .frame(alignment: .leading)
                    
                    Spacer()
                    
                    Button("Edit", systemImage: "pencil") {
                        CommandDetailWindowController.openWindow(for: CommandConfig(name: "New"))
                    }
                    .labelStyle(.iconOnly)
                    
                    Button("Remove", systemImage: "minus") {
                        
                    }
                    .labelStyle(.iconOnly)
                }
            }
            .onDelete(perform: viewModel.removeCommand)
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                CommandDetailWindowController.openWindow(for: CommandConfig(name: "New"))
            }
        }
    }
}

class CommandViewModel: ObservableObject {
    @Published var commands: [CommandConfig] = []
    
    func addCommand(name: String) {
        
    }
    
    func removeCommand(at offsets: IndexSet) {
        commands.remove(atOffsets: offsets)
    }
}

#Preview {
    CommandListView()
}
