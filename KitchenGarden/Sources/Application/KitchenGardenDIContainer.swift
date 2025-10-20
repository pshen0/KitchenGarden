@MainActor
final class KitchenGardenDIContainer {
    let router: AppRouter
    
    init(router: AppRouter) {
        self.router = router
    }
    
    lazy var homeModuleFactory: HomeFactory = {
        HomeFactoryImpl(externalDeps: HomeExternalDeps(appRouter: router))
    }()
    
    lazy var clipboardModuleFactory: ClipboardFactory = {
        ClipboardFactoryImpl(externalDeps: ClipboardExternalDeps(appRouter: router))
    }()
    
    lazy var tasksModuleFactory: TasksFactory = {
        TasksFactoryImpl(externalDeps: TasksExternalDeps(appRouter: router))
    }()
    
    lazy var pomodoroModuleFactory: PomodoroFactory = {
        PomodoroFactoryImpl(externalDeps: PomodoroExternalDeps(appRouter: router))
    }()
}
