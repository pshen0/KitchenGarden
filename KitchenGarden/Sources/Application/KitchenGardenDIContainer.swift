import SwiftData

@MainActor
final class KitchenGardenDIContainer {
    let router: AppRouter
    let modelContext: ModelContext
    
    init(router: AppRouter, modelContext: ModelContext) {
        self.router = router
        self.modelContext = modelContext
    }
    
    lazy var homeModuleFactory: HomeFactory = {
        HomeFactoryImpl(externalDeps: HomeExternalDeps(appRouter: router, modelContext: modelContext))
    }()
    
    lazy var clipboardModuleFactory: ClipboardFactory = {
        ClipboardFactoryImpl(externalDeps: ClipboardExternalDeps(
            appRouter: router,
            modelContext: modelContext))
    }()
    
    lazy var tasksModuleFactory: TasksFactory = {
        TasksFactoryImpl(externalDeps: TasksExternalDeps(
            appRouter: router,
            modelContext: modelContext
        ))
    }()
    
    lazy var pomodoroModuleFactory: PomodoroFactory = {
        PomodoroFactoryImpl(externalDeps: PomodoroExternalDeps(
            appRouter: router,
            modelContext: modelContext
        ))
    }()
}
