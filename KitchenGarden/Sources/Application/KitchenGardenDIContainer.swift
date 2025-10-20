@MainActor
final class KitchenGardenDIContainer {
    let router: AppRouter
    
    init(router: AppRouter) {
        self.router = router
    }
    
    lazy var homeModuleFactory: HomeFactory = {
        HomeFactoryImpl(externalDeps: HomeExternalDeps(appRouter: router))
    }()
}
