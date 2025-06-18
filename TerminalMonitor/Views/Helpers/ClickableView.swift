//
//  ClickableView.swift
//  TerminalMonitor
//
//  Created on 2025/6/4.
//

import SwiftUI

struct ClickableView: NSViewRepresentable {
    var onClick: (Bool) -> Void // Passes whether Command key is pressed

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let gesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onClick: onClick)
    }

    class Coordinator: NSObject {
        var onClick: (Bool) -> Void

        init(onClick: @escaping (Bool) -> Void) {
            self.onClick = onClick
        }

        @objc func handleClick(_ sender: NSClickGestureRecognizer) {
            let isCommandPressed = NSEvent.modifierFlags.contains(.command)
            onClick(isCommandPressed)
        }
    }
}
