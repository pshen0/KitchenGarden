import AppKit
import SwiftUI
import Combine
import Cocoa
import SwiftData

final class LauncherHotkeyManager: ObservableObject {
    private let windowManager: LauncherWindowManager
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init(router: AppRouter, modelContainer: ModelContainer) {
        self.windowManager = LauncherWindowManager(router: router, modelContainer: modelContainer)
        setupHotkeyTap()
    }


    private func setupHotkeyTap() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: LauncherHotkeyManager.hotkeyCallback,
            userInfo: refcon
        )

        guard let eventTap = eventTap else {
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private static let hotkeyCallback: CGEventTapCallBack = { proxy, type, event, refcon in
        guard type == .keyDown else { return Unmanaged.passUnretained(event) }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        let isCmd = flags.contains(.maskCommand)
        let isShift = flags.contains(.maskShift)
        let isSpace = keyCode == 49

        if isCmd && isShift && isSpace {
            let manager = Unmanaged<LauncherHotkeyManager>.fromOpaque(refcon!).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.windowManager.toggleLauncher()
            }
            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    deinit {
        if let eventTap = eventTap {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CFMachPortInvalidate(eventTap)
        }
    }
}
