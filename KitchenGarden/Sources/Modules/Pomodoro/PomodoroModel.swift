import Foundation

struct PomodoroModel: Identifiable {
    let id: UUID
    let taskId: UUID?
    let startTime: Date
    let endTime: Date
    let actualWorkTime: TimeInterval
    let targetWorkTime: TimeInterval
    let completedIntervals: Int
    let totalIntervals: Int
    
    init(id: UUID = UUID(),
         taskId: UUID? = nil,
         startTime: Date,
         endTime: Date,
         actualWorkTime: TimeInterval,
         targetWorkTime: TimeInterval,
         completedIntervals: Int,
         totalIntervals: Int) {
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

extension PomodoroModel {
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
    
    var isCompleted: Bool {
        return completedIntervals >= totalIntervals
    }
}
