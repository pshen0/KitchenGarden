@MainActor
protocol ClipboardRouter {
    func routeTo(_ destination: ClipboardRouterDestination)
}

enum ClipboardRouterDestination {
}


final class ClipboardRouterImpl: ClipboardRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Public Methods
    func routeTo(_ destination: ClipboardRouterDestination) {

    }

    // MARK: - Private Properties
    
    private let appRouter: AppRouter
}
