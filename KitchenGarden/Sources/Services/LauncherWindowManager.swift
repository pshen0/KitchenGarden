import SwiftUI
import AppKit
import SwiftData

final class LauncherWindowManager {
    private var panel: NSPanel?
    private let router: AppRouter
    private let modelContainer: ModelContainer

    init(router: AppRouter, modelContainer: ModelContainer) {
        self.router = router
        self.modelContainer = modelContainer
    }
    
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
                .environmentObject(router)
                .modelContainer(modelContainer)
            
            let hostingController = NSHostingController(rootView: contentView)
            
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 50),
                styleMask: [.nonactivatingPanel, .fullSizeContentView, .titled],
                backing: .buffered,
                defer: false
            )
            
            panel.title = "LauncherWindow"
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

        NSApp.activate(ignoringOtherApps: true)

        DispatchQueue.main.async {
            if let panel = self.panel,
               let hostingView = panel.contentView?.subviews.first,
               let textField = self.findTextField(in: hostingView) {
                panel.makeFirstResponder(textField)
            }
        }

    }
    
    func closeLauncher() {
        panel?.orderOut(nil)
    }
    
    private func findTextField(in view: NSView) -> NSTextField? {
        if let textField = view as? NSTextField {
            return textField
        }
        
        for subview in view.subviews {
            if let textField = findTextField(in: subview) {
                return textField
            }
        }
        
        return nil
    }
}
