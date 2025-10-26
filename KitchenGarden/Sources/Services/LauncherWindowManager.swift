import SwiftUI
import AppKit

final class LauncherWindowManager {
    private var panel: NSPanel?
    
    func toggleLauncher() {
        if let window = self.panel, window.isVisible {
            closeLauncher()
        } else {
            showLauncher()
        }
    }
    
    private func showLauncher() {
        if self.panel == nil {
            let contentView = LauncherView()
            
            let hostingController = NSHostingController(rootView: contentView)
            
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 50),
                styleMask: [.nonactivatingPanel, .fullSizeContentView, .titled],
                backing: .buffered,
                defer: false
            )
            
            panel.isFloatingPanel = true
            panel.hidesOnDeactivate = false
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.isOpaque = false
            panel.backgroundColor = NSColor.clear
            panel.hasShadow = true
            panel.level = .statusBar
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.contentViewController = hostingController
            if let textField = hostingController.view.subviews.first(where: { $0 is NSTextField }) as? NSTextField {
                panel.makeFirstResponder(textField)
            }
            panel.isReleasedWhenClosed = false
            panel.center()
            
            self.panel = panel
        }
        
        panel?.makeKeyAndOrderFront(nil)
        panel?.orderFrontRegardless()
        panel?.makeFirstResponder(panel?.contentView)
        NSApp.activate(ignoringOtherApps: true)

    }
    
    func closeLauncher() {
        panel?.orderOut(nil)
    }
}
