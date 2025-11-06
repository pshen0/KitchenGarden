import SwiftUI
import Combine
#if os(macOS)
import AppKit
#endif

@MainActor
protocol PomodoroViewModel: ObservableObject {
    var taskTitle: String { get set }
    var totalWorkSessions: Int { get set }
    var completedWorkSessions: Int { get set }
    var workDuration: TimeInterval { get set }
    var breakDuration: TimeInterval { get set }
    var isFocusModeEnabled: Bool { get set }
    var isFallingTomatoesEnabled: Bool { get set }

    var isRunning: Bool { get }
    var isPomodoroStarted: Bool { get }
    var isBreakPeriod: Bool { get }
    var remainingTime: TimeInterval { get }

    func startTimer()
    func pauseTimer()
    func resetTimer()
    func completeWorkSession()
    func toggleFocusMode()
}

@MainActor
final class PomodoroViewModelImpl: PomodoroViewModel {
    
    // MARK: - Internal Properties
    @Published var taskTitle: String = "Focus session"
    @Published var totalWorkSessions: Int = 4 {
        didSet {
            let clamped = max(1, min(10, totalWorkSessions))
            if totalWorkSessions != clamped {
                totalWorkSessions = clamped
            }
        }
    }
    @Published var completedWorkSessions: Int = 1
    @Published var workDuration: TimeInterval = 25 * 60 {
        didSet {
            let clamped = max(60, min(3600, workDuration))
            if workDuration != clamped {
                workDuration = clamped
                return
            }
            if !isPomodoroStarted && !isBreakPeriod {
                remainingTime = workDuration
            }
        }
    }
    @Published var breakDuration: TimeInterval = 5 * 60 {
        didSet {
            let clamped = max(60, min(3600, breakDuration))
            if breakDuration != clamped {
                breakDuration = clamped
                return
            }
            if !isPomodoroStarted && isBreakPeriod {
                remainingTime = breakDuration
            }
        }
    }
    @Published var isFocusModeEnabled: Bool = false
    @Published var isFallingTomatoesEnabled: Bool = true

    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isPomodoroStarted: Bool = false
    @Published private(set) var isBreakPeriod: Bool = false
    @Published private(set) var remainingTime: TimeInterval = 25 * 60
    
    
    // MARK: - Init
    
    init(interactor: PomodoroInteractor, router: PomodoroRouter) {
        self.interactor = interactor
        self.router = router
        remainingTime = workDuration
        setupTimer()
    }

    // MARK: - Focus Mode

    func toggleFocusMode() {
        isFocusModeEnabled.toggle()
        if isFocusModeEnabled {
            enableSystemFocusIfPossible()
        } else {
            disableSystemFocusIfPossible()
        }
    }
    
    // MARK: - Public Methods
    func startTimer() {
        if !isPomodoroStarted {
            isPomodoroStarted = true
            isBreakPeriod = false
            remainingTime = workDuration
            startTime = Date()
        } else if let pausedTime = pausedTime {
            let currentDuration = isBreakPeriod ? breakDuration : workDuration
            startTime = Date().addingTimeInterval(-(currentDuration - pausedTime))
            self.pausedTime = nil
        } else if startTime == nil {
            let currentDuration = isBreakPeriod ? breakDuration : workDuration
            remainingTime = currentDuration
            startTime = Date()
        }
        isRunning = true
    }
    
    func pauseTimer() {
        isRunning = false
        if let startTime = startTime {
            let currentDuration = isBreakPeriod ? breakDuration : workDuration
            let elapsed = Date().timeIntervalSince(startTime)
            pausedTime = max(0, currentDuration - elapsed)
            self.startTime = nil
        }
    }
    
    func resetTimer() {
        isRunning = false
        isPomodoroStarted = false
        isBreakPeriod = false
        remainingTime = workDuration
        startTime = nil
        pausedTime = nil
        completedWorkSessions = 1
    }
    
    func completeWorkSession() {
        pausedTime = nil
        
        if isBreakPeriod {
            if completedWorkSessions >= totalWorkSessions {
                isPomodoroStarted = false
                isRunning = false
                isBreakPeriod = false
                remainingTime = workDuration
                startTime = nil
            } else {
                completedWorkSessions = min(completedWorkSessions + 1, totalWorkSessions)
                isBreakPeriod = false
                remainingTime = workDuration
                startTime = Date()
                isRunning = true
                if !isPomodoroStarted {
                    isPomodoroStarted = true
                }
            }
        } else {
            if !isPomodoroStarted {
                isPomodoroStarted = true
            }

            if completedWorkSessions >= totalWorkSessions {
                isPomodoroStarted = false
                isRunning = false
                isBreakPeriod = false
                remainingTime = workDuration
                startTime = nil
                completedWorkSessions = 1
            } else {
                isBreakPeriod = true
                remainingTime = breakDuration
                startTime = Date()
                isRunning = true
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let interactor: PomodoroInteractor
    private let router: PomodoroRouter
    private var startTime: Date?
    private var pausedTime: TimeInterval?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Methods
    
    private func setupTimer() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
            .store(in: &cancellables)
    }
    
    private func updateTimer() {
        guard isPomodoroStarted else { return }
        
        if isRunning, let startTime = startTime {
            let currentDuration = isBreakPeriod ? breakDuration : workDuration
            let elapsed = Date().timeIntervalSince(startTime)
            let newRemainingTime = max(0, currentDuration - elapsed)
            
            if newRemainingTime <= 0 {
                remainingTime = 0
                
                if !isBreakPeriod {
                    completedWorkSessions = min(completedWorkSessions + 1, totalWorkSessions)
                    if completedWorkSessions >= totalWorkSessions {
                        isRunning = false
                        isPomodoroStarted = false
                        isBreakPeriod = false
                        completedWorkSessions = 1
                    } else {
                        startBreakPeriod()
                    }
                } else {
                    isRunning = false
                    isPomodoroStarted = false
                    isBreakPeriod = false
                    completedWorkSessions = 1
                }
            } else {
                remainingTime = newRemainingTime
            }
        } else if !isRunning {
            if let pausedTime = pausedTime {
                remainingTime = pausedTime
            }
        }
    }
    
    private func startBreakPeriod() {
        isBreakPeriod = true
        remainingTime = breakDuration
        startTime = Date()
    }

    private func enableSystemFocusIfPossible() {
        #if os(macOS)
        let shortcutName = "Enable Do Not Disturb"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = ["run", shortcutName]
        do {
            try process.run()
        } catch {
            openSystemSettingsFocus()
        }
        #elseif canImport(UIKit)
        let shortcutName = "Enable Do Not Disturb"
        if let encoded = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "shortcuts://run-shortcut?name=\(encoded)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings, options: [:], completionHandler: nil)
        }
        #else
        openSystemSettingsFocus()
        #endif
    }

    private func disableSystemFocusIfPossible() {
        #if os(macOS)
        let shortcutName = "Disable Do Not Disturb"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = ["run", shortcutName]
        do {
            try process.run()
        } catch {
            openSystemSettingsFocus()
        }
        #elseif canImport(UIKit)
        let shortcutName = "Disable Do Not Disturb"
        if let encoded = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "shortcuts://run-shortcut?name=\(encoded)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings, options: [:], completionHandler: nil)
        }
        #else
        openSystemSettingsFocus()
        #endif
    }

    private func openSystemSettingsFocus() {
        #if os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.launchApplication("System Settings")
        }
        #elseif canImport(UIKit)
        if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings, options: [:], completionHandler: nil)
        }
        #endif
    }
}

