import SwiftUI
import Combine
import SwiftData
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
    
    var selectedTask: TaskItem? { get set }
    var availableTasks: [TaskItem] { get }

    var isRunning: Bool { get }
    var isPomodoroStarted: Bool { get }
    var isBreakPeriod: Bool { get }
    var remainingTime: TimeInterval { get }

    func startTimer()
    func pauseTimer()
    func resetTimer()
    func fetchAvailableTasks()
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
    
    @Published var selectedTask: TaskItem?
    @Published var availableTasks: [TaskItem] = []

    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isPomodoroStarted: Bool = false
    @Published private(set) var isBreakPeriod: Bool = false
    @Published private(set) var remainingTime: TimeInterval = 25 * 60
    
    // MARK: - Init
    
    init(interactor: PomodoroInteractor, router: PomodoroRouter, modelContext: ModelContext) {
        self.interactor = interactor
        self.router = router
        self.modelContext = modelContext
        self.remainingTime = workDuration

        setupTimer()
        fetchAvailableTasks()
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
            currentSessionStartTime = Date()
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
    
    func fetchAvailableTasks() {
        do {
            let descriptor = FetchDescriptor<TaskItem>()
            let taskItems = try modelContext.fetch(descriptor)
            availableTasks = taskItems.filter { $0.status != .completed }
            print("✅ Loaded \(availableTasks.count) available tasks")
        } catch {
            print("Failed to fetch tasks: \(error)")
            availableTasks = []
        }
    }
    
    func completeWorkSession() {
        pausedTime = nil
        
        if !isBreakPeriod {
            // досрочное завершение рабочей сессии
            let actualWorkTime: TimeInterval
            if let startTime = startTime {
                actualWorkTime = min(Date().timeIntervalSince(startTime), workDuration)
            } else {
                actualWorkTime = workDuration
            }
            
            savePomodoroSession(actualWorkTime: actualWorkTime)
            
            if let task = selectedTask {
                task.timeSpent += actualWorkTime
                task.updatedAt = Date()
                
                do {
                    try modelContext.save()
                    print("✅ POMODORO DEBUG: Saved \(Int(actualWorkTime/60))min to task '\(task.title)'")
                    print("   Total time spent: \(Int(task.timeSpent/60))min")
                } catch {
                    print("❌ POMODORO DEBUG: Failed to save task time: \(error)")
                }
            }
        }
        
        // Остальная логика без изменений
        if isBreakPeriod {
            if completedWorkSessions > totalWorkSessions {
                isPomodoroStarted = false
                isRunning = false
                isBreakPeriod = false
                remainingTime = workDuration
                startTime = nil
                currentSessionStartTime = nil
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
                currentSessionStartTime = nil
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
    private var currentSessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    private let modelContext: ModelContext
    
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
                    // авто завершение рабочей сессии
                    let actualWorkTime = workDuration // полное время работы
                    
                    savePomodoroSession(actualWorkTime: actualWorkTime)
                    
                    // сохраняем время в задачу
                    if let task = selectedTask {
                        task.timeSpent += actualWorkTime
                        task.updatedAt = Date()
                        
                        do {
                            try modelContext.save()
                            print("✅ POMODORO DEBUG: Saved \(Int(actualWorkTime/60))min to task '\(task.title)'")
                            print("   Total time spent: \(Int(task.timeSpent/60))min")
                        } catch {
                            print("❌ POMODORO DEBUG: Failed to save task time: \(error)")
                        }
                    }
                    
                    if completedWorkSessions + 1 > totalWorkSessions {
                        // все сессии завершены
                        isRunning = false
                        isPomodoroStarted = false
                        isBreakPeriod = false
                        completedWorkSessions = 1
                        currentSessionStartTime = nil
                        print("🎉 POMODORO: All sessions completed!")
                    } else {
                        // переходим в перерыв
                        startBreakPeriod()
                    }
                } else {
                    // завершение перерыва
                    isBreakPeriod = false
                    completedWorkSessions += 1
                    remainingTime = workDuration
                    self.startTime = Date()
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
    
    private func savePomodoroSession(actualWorkTime: TimeInterval) {
        guard let sessionStartTime = currentSessionStartTime else {
                print("❌ POMODORO DEBUG: No currentSessionStartTime!")
                return
            }
        
        let pomodoroItem = PomodoroItem(
            taskId: selectedTask?.id,
            startTime: sessionStartTime,
            endTime: Date(),
            actualWorkTime: actualWorkTime,
            targetWorkTime: workDuration,
            completedIntervals: 1,
            totalIntervals: 1
        )
        
        modelContext.insert(pomodoroItem)
        
        do {
            try modelContext.save()
            print("POMODORO DEBUG: Saved pomodoro session - \(Int(actualWorkTime/60))min")
            
            NotificationCenter.default.post(name: .pomodoroSessionsDidChange, object: nil)
        } catch {
            print("❌ POMODORO DEBUG: Failed to save pomodoro session: \(error)")
        }
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

extension Notification.Name {
    static let pomodoroSessionsDidChange = Notification.Name("pomodoroSessionsDidChange")
}
