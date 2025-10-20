@MainActor
protocol PomodoroRouter {
    func routeTo(_ destination: PomodoroRouterDestination)
}

enum PomodoroRouterDestination {
}


final class PomodoroRouterImpl: PomodoroRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Public Methods
    func routeTo(_ destination: PomodoroRouterDestination) {

    }

    // MARK: - Private Properties
    
    private let appRouter: AppRouter
}
