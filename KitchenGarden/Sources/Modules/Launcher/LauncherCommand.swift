import Foundation

enum LauncherCommand: String, CaseIterable {
    case home
    case tasks
    case clipboard
    case pomodoro
    case help
    case task // Special case for task creation command
    
    var description: String {
        switch self {
        case .home:
            return "open Home"
        case .tasks:
            return "open Tasks board"
        case .clipboard:
            return "open Clipboard manager"
        case .pomodoro:
            return "start Pomodoro timer"
        case .task:
            return "create new task: task {name} {dd.MM.yyyy} {HH:mm}"
        case .help:
            return "show available commands"
        }
    }
    
    struct TaskInfo {
        let name: String
        let date: Date
    }
    
    static func parseTaskCommand(_ input: String) -> TaskInfo? {
        // Pattern matches: task {name} {dd.MM.yyyy} {HH:mm} [!1-3] [#tag1 #tag2 ...]
        let pattern = #"^task\s+([^\{]*?)\s+(\d{2}\.\d{2}\.\d{4})\s+(\d{2}:\d{2})(?:\s+!([1-3]))?\s*((?:#\w+\s*)*)$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }
        
        let nameRange = Range(match.range(at: 1), in: input)
        let dateRange = Range(match.range(at: 2), in: input)
        let timeRange = Range(match.range(at: 3), in: input)
        let priorityRange = Range(match.range(at: 4), in: input)
        let tagsRange = Range(match.range(at: 5), in: input)
        
        guard let nameRange = nameRange,
              let dateRange = dateRange,
              let timeRange = timeRange else {
            return nil
        }
        
        let name = String(input[nameRange]).trimmingCharacters(in: .whitespaces)
        let dateString = String(input[dateRange])
        let timeString = String(input[timeRange])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        guard let date = formatter.date(from: "\(dateString) \(timeString)") else {
            return nil
        }
        
        return TaskInfo(name: name, date: date)
    }
}

