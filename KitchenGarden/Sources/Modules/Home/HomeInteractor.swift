import Foundation

protocol HomeInteractor {
    func toBusinessModel(_ taskItem: TaskItem) -> TasksModel
}

final class HomeInteractorImpl: HomeInteractor {
    
    init() {

    }
    
    func toBusinessModel(_ taskItem: TaskItem) -> TasksModel {
        return TasksModel(
            id: taskItem.id,
            title: taskItem.title,
            tags: taskItem.tags,
            priority: taskItem.priority,
            deadline: taskItem.deadline,
            status: taskItem.status,
            timeSpent: taskItem.timeSpent
        )
    }
}


