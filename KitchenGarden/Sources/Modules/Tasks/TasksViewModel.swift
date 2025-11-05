import SwiftUI
import Combine
import SwiftData

@MainActor
protocol TasksViewModel: ObservableObject {
    var tasks: [TasksModel] { get }
    var filteredTasks: [TasksModel] { get }
    var priorityFilter: Int? { get set }
    func fetchTasks()
    func addTask(_ task: TasksModel)
    func updateTask(_ task: TasksModel)
    func deleteTask(_ task: TasksModel)
}

@MainActor
final class TasksViewModelImpl: TasksViewModel {
    
    // MARK: - Internal Properties
    
    @Published var tasks: [TasksModel] = []
    @Published var priorityFilter: Int? = nil
    
    // MARK: - Computed Properties
    
    var filteredTasks: [TasksModel] {
        switch priorityFilter {
        case nil:
            return tasks
        case -1:
            return tasks.filter { $0.priority == nil }
        case let priority?:
            return tasks.filter { $0.priority == priority } 
        }
    }
    
    // MARK: - Init
    
    init(interactor: TasksInteractor, router: TasksRouter, modelContext: ModelContext) {
            self.interactor = interactor
            self.router = router
            self.modelContext = modelContext
            fetchTasks()
        }
    
    // MARK: - Public Methods
    
    func fetchTasks() {
            do {
                let descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.createdAt)])
                let taskItems = try modelContext.fetch(descriptor)
                tasks = taskItems.compactMap { interactor.toBusinessModel($0) }
            } catch {
                print("Failed to fetch tasks: \(error)")
                tasks = []
            }
        }
        
    func addTask(_ task: TasksModel) {
        let taskItem = interactor.toDataModel(task)
        modelContext.insert(taskItem)
        
        do {
            try modelContext.save()
            tasks.append(task)
        } catch {
            print("Failed to save task: \(error)")
        }
    }
    
    func updateTask(_ task: TasksModel) {
        do {
            let descriptor = FetchDescriptor<TaskItem>()
            let taskItems = try modelContext.fetch(descriptor)
            
            if let taskItem = taskItems.first(where: { $0.id == task.id }) {
                taskItem.title = task.title
                taskItem.tags = task.tags
                taskItem.priority = task.priority
                taskItem.deadline = task.deadline
                taskItem.status = task.status
                taskItem.timeSpent = task.timeSpent
                taskItem.updatedAt = Date()
                
                try modelContext.save()
                
                // Обновляем локальный массив
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = task
                }
            }
        } catch {
            print("Failed to update task: \(error)")
        }
    }
    
    func deleteTask(_ task: TasksModel) {
        do {
            let descriptor = FetchDescriptor<TaskItem>()
            let taskItems = try modelContext.fetch(descriptor)
            
            if let taskItem = taskItems.first(where: { $0.id == task.id }) {
                modelContext.delete(taskItem)
                try modelContext.save()
                
                tasks.removeAll { $0.id == task.id }
            }
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
    
    // MARK: - Private Properties
    
    private let interactor: TasksInteractor
    private let router: TasksRouter
    private let modelContext: ModelContext
}
