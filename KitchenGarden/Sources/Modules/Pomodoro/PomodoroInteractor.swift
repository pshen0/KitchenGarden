import Foundation
import SwiftData

protocol PomodoroInteractor {
    func toBusinessModel(_ item: PomodoroItem) -> PomodoroModel
    func toDataModel(_ model: PomodoroModel) -> PomodoroItem
}

final class PomodoroInteractorImpl: PomodoroInteractor {
    
    init() {}
    
    func toBusinessModel(_ item: PomodoroItem) -> PomodoroModel {
        return PomodoroModel(
            id: item.id,
            taskId: item.taskId,
            startTime: item.startTime,
            endTime: item.endTime,
            actualWorkTime: item.actualWorkTime,
            targetWorkTime: item.targetWorkTime,
            completedIntervals: item.completedIntervals,
            totalIntervals: item.totalIntervals
        )
    }
    
    func toDataModel(_ model: PomodoroModel) -> PomodoroItem {
        return PomodoroItem(
            id: model.id,
            taskId: model.taskId,
            startTime: model.startTime,
            endTime: model.endTime,
            actualWorkTime: model.actualWorkTime,
            targetWorkTime: model.targetWorkTime,
            completedIntervals: model.completedIntervals,
            totalIntervals: model.totalIntervals
        )
    }
}
