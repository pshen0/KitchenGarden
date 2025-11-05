import Foundation
import SwiftData

protocol TasksInteractor {
    func toBusinessModel(_ taskItem: TaskItem) -> TasksModel
    func toDataModel(_ tasksModel: TasksModel) -> TaskItem
}

final class TasksInteractorImpl: TasksInteractor {
    
    // MARK: - Init
    
    init() {
    }
    
    // MARK: - Public Methods
    
    func toBusinessModel(_ taskItem: TaskItem) -> TasksModel {
        return TasksModel(
            title: taskItem.title,
            tags: taskItem.tags,
            priority: taskItem.priority,
            deadline: taskItem.deadline,
            status: taskItem.status,
            timeSpent: taskItem.timeSpent
        )
    }
    
    func toDataModel(_ tasksModel: TasksModel) -> TaskItem {
        return TaskItem(
            title: tasksModel.title,
            tags: tasksModel.tags,
            priority: tasksModel.priority,
            deadline: tasksModel.deadline,
            status: tasksModel.status,
            timeSpent: tasksModel.timeSpent
        )
    }
}
