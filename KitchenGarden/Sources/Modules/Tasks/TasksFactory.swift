import SwiftUI
import SwiftData

@MainActor
protocol TasksFactory {
    func makeTasksScreen() -> TasksView<TasksViewModelImpl>
}

struct TasksFactoryImpl: TasksFactory {
    
    // MARK: - Init
    
    init(externalDeps: TasksExternalDeps) {
        self.externalDeps = externalDeps
    }
    
    // MARK: - Public Methods
    
    func makeTasksScreen() -> TasksView<TasksViewModelImpl> {
        let router = TasksRouterImpl(
            appRouter: externalDeps.appRouter
        )
        let interactor = TasksInteractorImpl()
        let viewModel = TasksViewModelImpl(interactor: interactor, router: router)
        let tasksView = TasksView(viewModel: viewModel)
        return tasksView
    }
    
    // MARK: - Private Properties
    
    private let externalDeps: TasksExternalDeps
}
