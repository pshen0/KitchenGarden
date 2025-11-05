import Foundation

struct TasksModel {
    let id: UUID
    var title: String
    var tags: [String]
    var priority: Int
    var deadline: Date?
    var status: TaskStatus
    var timeSpent: TimeInterval
    
    init(id: UUID = UUID(), title: String, tags: [String] = [],
         priority: Int = 1, deadline: Date? = nil,
         status: TaskStatus = .created, timeSpent: TimeInterval = 0) {
        self.id = id
        self.title = title
        self.tags = tags
        self.priority = priority
        self.deadline = deadline
        self.status = status
        self.timeSpent = timeSpent
    }
}
