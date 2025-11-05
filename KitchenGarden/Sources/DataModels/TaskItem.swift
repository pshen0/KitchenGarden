import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var tags: [String]
    var priority: Int?
    var deadline: Date?
    var statusValue: Int
    var timeSpent: TimeInterval
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, tags: [String] = [], priority: Int? = nil,
         deadline: Date? = nil, status: TaskStatus = .created,
         timeSpent: TimeInterval = 0) {
        self.id = id
        self.title = title
        self.tags = tags
        self.priority = priority
        self.deadline = deadline
        self.statusValue = status.rawValue
        self.timeSpent = timeSpent
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension TaskItem {
    var status: TaskStatus {
        get { TaskStatus(rawValue: statusValue) ?? .created }
        set { statusValue = newValue.rawValue }
    }
}

