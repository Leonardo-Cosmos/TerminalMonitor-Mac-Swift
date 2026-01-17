//
//  CommandListItemView.swift
//  TerminalMonitor
//
//  Created on 2025/11/29.
//

import SwiftUI

struct CommandListItemView: View {
    
    @Binding var command: CommandConfig
    
    @Binding var runningSet: Set<UUID>
    
    @State var isHoveringStart = false
    
    @State var isHoveringStop = false
    
    var body: some View {
        HStack {
            Text(command.name)
                .frame(alignment: .leading)
            
            Spacer()
            
            if runningSet.contains(command.id) {
                SymbolButton(systemImage: "stop.fill", symbolColor: .red) {
                    CommandListViewHelper.stopCommand(command)
                }
                .help("Stop")
            }
            
            SymbolButton(systemImage: "play.fill", symbolColor: .green) {
                CommandListViewHelper.startCommand(command)
            }
            .help("Start")
        }
    }
}

#Preview {
    CommandListItemView(
        command: Binding.constant(previewCommandConfigs()[0]),
        runningSet: Binding.constant([])
    )
}
