import Foundation

public struct TasksExternalDeps {
    let appRouter: AppRouter
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
}
