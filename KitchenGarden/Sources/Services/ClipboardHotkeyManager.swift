import AppKit
import SwiftUI
import SwiftData

@MainActor
final class ClipboardHotkeyManager {
    private let modelContext: ModelContext
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private lazy var viewModel: ClipboardHotkeyViewModel = {
            let interactor = ClipboardInteractorImpl()
            let router = ClipboardRouterImpl(appRouter: AppRouter())
            return ClipboardHotkeyViewModel(
                interactor: interactor,
                modelContext: modelContext
            )
        }()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupHotkeyTap()
        
        viewModel.startMonitoring()
        viewModel.fetchClipboardHistory()
    }

    private func setupHotkeyTap() {
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: ClipboardHotkeyManager.hotkeyCallback,
            userInfo: refcon
        )

        guard let eventTap else {
            print("Failed to create event tap. Did you enable Accessibility?")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        print("Clipboard hotkeys registered")
    }

    private static let hotkeyCallback: CGEventTapCallBack = { _, type, event, refcon in
        guard type == .keyDown else { return Unmanaged.passUnretained(event) }

        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        let isCmd = flags.contains(.maskCommand)
        let isShift = flags.contains(.maskShift)
        let isOpt = flags.contains(.maskAlternate)
        let isCtrl = flags.contains(.maskControl)
        
        let otherModifiersPressed = isShift || isOpt || isCtrl

        let keyMapping: [Int: Int] = [
                18: 0,  // 1
                19: 1,  // 2
                20: 2,  // 3
                21: 3,  // 4
                23: 4,  // 5
                22: 5,  // 6
                26: 6,  // 7
                28: 7   // 8
            ]
        
        if let index = keyMapping[keyCode], isCmd && !otherModifiersPressed {

            let manager = Unmanaged<ClipboardHotkeyManager>
                .fromOpaque(refcon!)
                .takeUnretainedValue()

            DispatchQueue.main.async {
                manager.handle(Int(index))
            }

            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    private func handle(_ index: Int) {
        print("Hotkey CMD+\(index + 1)")
        
        viewModel.fetchClipboardHistory()

        switch index {
        case 0...2:
            if let item = viewModel.getPinnedItem(at: index) {
                viewModel.copyItem(item)
            }
        case 3...7:
            let recentIndex = index - 3
            if let item = viewModel.getRecentItem(at: recentIndex) {
                viewModel.copyItem(item)
            }
        default:
            break
        }
    }
    
    deinit {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            }
            CFMachPortInvalidate(eventTap)
        }
        print("Hotkeys unregistered")
    }
}
