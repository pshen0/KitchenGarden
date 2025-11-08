import Foundation
import SwiftData

@Model
final class PomodoroItem {
    var id: UUID
    var taskId: UUID?
    var startTime: Date
    var endTime: Date
    var actualWorkTime: TimeInterval
    var targetWorkTime: TimeInterval
    var completedIntervals: Int
    var totalIntervals: Int
    
    init(id: UUID = UUID(),
         taskId: UUID? = nil,
         startTime: Date = Date(),
         endTime: Date = Date(),
         actualWorkTime: TimeInterval,
         targetWorkTime: TimeInterval,
         completedIntervals: Int = 1,
         totalIntervals: Int = 1) {
        self.id = id
        self.taskId = taskId
        self.startTime = startTime
        self.endTime = endTime
        self.actualWorkTime = actualWorkTime
        self.targetWorkTime = targetWorkTime
        self.completedIntervals = completedIntervals
        self.totalIntervals = totalIntervals
    }
}

extension PomodoroItem {
    var totalDuration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var efficiency: Double {
        guard targetWorkTime > 0 else { return 0 }
        return min(actualWorkTime / targetWorkTime, 1.0)
    }
    
    var actualWorkTimeInMinutes: Int {
        return Int(actualWorkTime / 60)
    }
    
    var actualWorkTimeInHours: Double {
        return actualWorkTime / 3600.0
    }
}
