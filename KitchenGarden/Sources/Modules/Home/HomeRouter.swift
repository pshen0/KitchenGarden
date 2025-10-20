@MainActor
protocol HomeRouter {
    func routeTo(_ destination: HomeRouterDestination)
}

enum HomeRouterDestination {
    case pomodoro
    case clipboard
    case tasks
}


final class HomeRouterImpl: HomeRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Public Methods
    func routeTo(_ destination: HomeRouterDestination) {
        switch destination {
        case .clipboard:
            appRouter.setRoot(.clipboard)
        case .pomodoro:
            appRouter.setRoot(.pomodoro)
        case .tasks:
            appRouter.setRoot(.tasks)
        }
    }

    // MARK: - Private Properties
    
    private let appRouter: AppRouter
}
