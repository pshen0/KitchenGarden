@MainActor
protocol TasksRouter {
    func routeTo(_ destination: TasksRouterDestination)
}

enum TasksRouterDestination {

}


final class TasksRouterImpl: TasksRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Public Methods
    func routeTo(_ destination: TasksRouterDestination) {

    }

    // MARK: - Private Properties
    
    private let appRouter: AppRouter
}
