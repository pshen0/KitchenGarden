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
