import SwiftUI
import Combine
import SwiftData

enum TaskPeriod: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
}

@MainActor
protocol HomeViewModel: ObservableObject {
    func loadTasks()
    func routeToPomodoro()
}

@MainActor
final class HomeViewModelImpl: HomeViewModel {
    
    // MARK: - Internal Properties
    @Published var allTasks: [TasksModel] = []
    @Published var tasksPeriod: TaskPeriod = .today
    @Published var statsPeriod: TaskPeriod = .today
    
    var incompleteTasks: [TasksModel] {
        let now = Date()
        let calendar = Calendar.current
        let filtered = allTasks.filter { task in
            guard task.status != .completed else { return false }
            guard let deadline = task.deadline else { return true }
            
            switch tasksPeriod {
            case .today:
                return calendar.isDateInToday(deadline)
            case .week:
                return calendar.isDate(deadline, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(deadline, equalTo: now, toGranularity: .month)
            }
        }
        return Array(filtered.prefix(7))
    }
    
    struct StatBar {
        let period: String
        let value: Double
        var valueString: String { String(Int(value)) }
    }
    
    struct Stats {
        var totalTime: Double
        var avgTime: Double
        var totalTasks: Int
        var chartData: [StatBar]
        
        var totalTimeString: String {
            if totalTime < 1.0 {
                return "\(Int(totalTime * 60))m"
            } else if totalTime == Double(Int(totalTime)) {
                return "\(Int(totalTime))h"
            } else {
                return String(format: "%.1fh", totalTime)
            }
        }
        var avgTimeString: String {
            if avgTime < 1.0 {
                return "\(Int(avgTime * 60))m"
            } else if avgTime == Double(Int(avgTime)) {
                return "\(Int(avgTime))h"
            } else {
                return String(format: "%.1fh", avgTime)
            }
        }
    }
    
    var stats: Stats {
        calculateRealStats()
        /*
        switch statsPeriod {
        case .today:
            let periods = ["0-4h", "4-8h", "8-12h", "12-16h", "16-20h", "20-24h"]
            let values = [1.0, 0.5, 2.0, 1.5, 1.0, 0.5]
            let tasksDone = [1, 0, 2, 1, 1, 0]
            let total = values.reduce(0,+)
            let avg = values.reduce(0,+)/Double(values.count)
            return Stats(totalTime: total,
                         avgTime: avg,
                         totalTasks: tasksDone.reduce(0,+),
                         chartData: zip(periods, values).map { StatBar(period: $0, value: $1*40) })
        case .week:
            let periods = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
            let values: [Double] = [3,2,4,3,5,2,1].map { Double($0) }
            let tasksDone = [2,1,3,2,4,1,1]
            
            let total = values.reduce(0, +)
            let avg = total / Double(values.count)
            
            return Stats(
                totalTime: total,
                avgTime: avg,
                totalTasks: tasksDone.reduce(0, +),
                chartData: zip(periods, values).map { StatBar(period: $0.0, value: $0.1 * 20) } 
            )        case .month:
            let days = Array(1...30).map { "Day \($0)" }
            let values = (1...30).map { _ in Double.random(in: 1...5) }
            let tasksDone = (1...30).map { _ in Int.random(in: 0...3) }
            let total = values.reduce(0,+)
            let avg = values.reduce(0,+)/Double(values.count)
            return Stats(totalTime: total,
                         avgTime: avg,
                         totalTasks: tasksDone.reduce(0,+),
                         chartData: zip(days, values).map { StatBar(period: $0, value: $1*10) })
        }*/
    }
    
    // MARK: - Init
    
    init(interactor: HomeInteractor, router: HomeRouter, modelContext: ModelContext) {
        self.interactor = interactor
        self.router = router
        self.modelContext = modelContext
        
        NotificationCenter.default.addObserver(
            forName: .tasksDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadTasks()
        }
        
        NotificationCenter.default.addObserver(
            forName: .pomodoroSessionsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func loadTasks() {
        do {
            let descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.createdAt)])
            let taskItems = try modelContext.fetch(descriptor)
            allTasks = taskItems.compactMap { interactor.toBusinessModel($0) }
        } catch {
            print("Failed to fetch tasks: \(error)")
            allTasks = []
        }
    }
    
    func toggleTaskCompletion(_ task: TasksModel) {
        do {
            let descriptor = FetchDescriptor<TaskItem>()
            let taskItems = try modelContext.fetch(descriptor)
            
            guard let taskItem = taskItems.first(where: { $0.id == task.id }) else { return }
            
            taskItem.status = (taskItem.status == .completed) ? .created : .completed
            taskItem.updatedAt = Date()
            
            try modelContext.save()
            
            if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
                allTasks[index].status = taskItem.status
            }
            
        } catch {
            print("Failed to toggle task status: \(error)")
        }
    }
    
    func selectTaskPeriod(_ period: TaskPeriod) {
        tasksPeriod = period
    }
    
    func selectStatsPeriod(_ period: TaskPeriod) {
        statsPeriod = period
    }
    
    func routeToPomodoro() {
        router.routeTo(.pomodoro)
    }
    
    func flagColor(for priority: Int?) -> Color {
        switch priority {
        case 2:
            return Colors.redAccent
        case 1:
            return Colors.yellowAccent
        case 0:
            return Colors.greenAccent
        default:
            return Color.primary
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateRealStats() -> Stats {
        let calendar = Calendar.current
        let now = Date()
        
        // Получаем Pomodoro сессии за выбранный период
        let pomodoroSessions = fetchPomodoroSessions(for: statsPeriod)
        
        // Получаем выполненные задачи за выбранный период
        let completedTasks = fetchCompletedTasks(for: statsPeriod)
        
        // Рассчитываем общее время фокуса (в часах)
        let totalFocusTime = pomodoroSessions.reduce(0) { $0 + $1.actualWorkTimeInHours }
        
        // Рассчитываем среднее время фокуса
        let avgFocusTime = calculateAverageFocusTime(pomodoroSessions: pomodoroSessions, period: statsPeriod)
        
        let chartData = generateChartData(pomodoroSessions: pomodoroSessions, period: statsPeriod)
        
        return Stats(
            totalTime: totalFocusTime,
            avgTime: avgFocusTime,
            totalTasks: completedTasks.count,
            chartData: chartData
        )
    }
    
    private func fetchPomodoroSessions(for period: TaskPeriod) -> [PomodoroItem] {
        let calendar = Calendar.current
        let now = Date()
        
        do {
            let descriptor = FetchDescriptor<PomodoroItem>()
            let allSessions = try modelContext.fetch(descriptor)
            
            return allSessions.filter { session in
                switch period {
                case .today:
                    return calendar.isDateInToday(session.startTime)
                case .week:
                    return calendar.isDate(session.startTime, equalTo: now, toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(session.startTime, equalTo: now, toGranularity: .month)
                }
            }
        } catch {
            print("Failed to fetch pomodoro sessions: \(error)")
            return []
        }
    }
    
    private func fetchCompletedTasks(for period: TaskPeriod) -> [TaskItem] {
        let calendar = Calendar.current
        let now = Date()
        
        do {
            let descriptor = FetchDescriptor<TaskItem>()
            let allTasks = try modelContext.fetch(descriptor)
            
            return allTasks.filter { task in
                guard task.status == .completed else { return false }
                
                switch period {
                case .today:
                    return calendar.isDateInToday(task.updatedAt)
                case .week:
                    return calendar.isDate(task.updatedAt, equalTo: now, toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(task.updatedAt, equalTo: now, toGranularity: .month)
                }
            }
        } catch {
            print("Failed to fetch completed tasks: \(error)")
            return []
        }
    }
    
    private func calculateAverageFocusTime(pomodoroSessions: [PomodoroItem], period: TaskPeriod) -> Double {
        guard !pomodoroSessions.isEmpty else { return 0 }
        
        let totalHours = pomodoroSessions.reduce(0) { $0 + $1.actualWorkTimeInHours }
        
        switch period {
        case .today:
            return totalHours // За сегодня - просто общее время
        case .week:
            return totalHours / 7.0 // За неделю - среднее за день
        case .month:
            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
            return totalHours / Double(daysInMonth) // За месяц - среднее за день
        }
    }
    
    private func generateChartData(pomodoroSessions: [PomodoroItem], period: TaskPeriod) -> [StatBar] {
        let calendar = Calendar.current
        
        switch period {
        case .today:
            // Группируем по часам (6 периодов по 4 часа)
            let timeSlots = ["0-4h", "4-8h", "8-12h", "12-16h", "16-20h", "20-24h"]
            var hoursData = Array(repeating: 0.0, count: 6)
            
            for session in pomodoroSessions {
                let hour = calendar.component(.hour, from: session.startTime)
                let slotIndex = hour / 4
                if slotIndex < 6 {
                    hoursData[slotIndex] += session.actualWorkTimeInHours
                }
            }
            
            return zip(timeSlots, hoursData).map { StatBar(period: $0, value: $1 * 60) } // в минуты для графика
            
        case .week:
            let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            var daysData = Array(repeating: 0.0, count: 7)
            
            for session in pomodoroSessions {
                let weekday = (calendar.component(.weekday, from: session.startTime) + 5) % 7
                if weekday >= 0 && weekday < 7 {
                    daysData[weekday] += session.actualWorkTimeInHours
                }
            }
            
            return zip(weekdays, daysData).map { StatBar(period: $0, value: $1 * 60) } // в минуты для графика
            
        case .month:
            let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 30
            let days = Array(1...daysInMonth).map { "\($0)" } // Просто числа "1", "2", "3"...
            
            var dailyData = Array(repeating: 0.0, count: daysInMonth)
            
            for session in pomodoroSessions {
                let day = calendar.component(.day, from: session.startTime)
                if day >= 1 && day <= daysInMonth {
                    dailyData[day - 1] += session.actualWorkTimeInHours
                }
            }
            
            return zip(days, dailyData).map { StatBar(period: $0, value: $1 * 60) }
        }
    }
    
    // MARK: - Private Properties
    private let interactor: HomeInteractor
    private let router: HomeRouter
    private let modelContext: ModelContext
}
