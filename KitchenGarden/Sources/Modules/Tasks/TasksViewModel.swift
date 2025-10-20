import SwiftUI
import Combine

@MainActor
protocol TasksViewModel: ObservableObject {

}

@MainActor
final class TasksViewModelImpl: TasksViewModel {
    
    // MARK: - Internal Properties

    
    // MARK: - Init
    
    init(interactor: TasksInteractor, router: TasksRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Public Methods

    
    // MARK: - Private Properties
    
    private let interactor: TasksInteractor
    private let router: TasksRouter
}

