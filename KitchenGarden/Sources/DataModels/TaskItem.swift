import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var tags: [String]
    var priority: Int
    var deadline: Date?
    var statusValue: Int
    var timeSpent: TimeInterval
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, tags: [String] = [], priority: Int = 1,
         deadline: Date? = nil, status: TaskStatus = .created,
         timeSpent: TimeInterval = 0) {
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

enum TaskStatus: Int, CaseIterable {
    case created = 0
    case inProgress = 1
    case completed = 2
    
    var displayName: String {
        switch self {
        case .created: return "Created"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }
    
    var icon: String {
        switch self {
        case .created: return "circle"
        case .inProgress: return "play.circle"
        case .completed: return "checkmark.circle.fill"
        }
    }
}
