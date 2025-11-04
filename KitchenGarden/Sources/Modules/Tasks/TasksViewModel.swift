import SwiftUI
import Combine

@MainActor
protocol TasksViewModel: ObservableObject {
    var tasks: [TaskItem] { get }
}

@MainActor
final class TasksViewModelImpl: TasksViewModel {
    
    // MARK: - Internal Properties
    
    var tasks: [TaskItem] = []
    
    // MARK: - Init
    
    init(interactor: TasksInteractor, router: TasksRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Private Properties
    
    private let interactor: TasksInteractor
    private let router: TasksRouter
}
