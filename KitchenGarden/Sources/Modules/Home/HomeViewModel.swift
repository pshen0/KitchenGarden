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
        
        var totalTimeString: String { "\(Int(totalTime))h" }
        var avgTimeString: String { "\(Int(avgTime))h" }
    }
    
    var stats: Stats {
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
        }
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
    
    // MARK: - Private Properties
    private let interactor: HomeInteractor
    private let router: HomeRouter
    private let modelContext: ModelContext
}
