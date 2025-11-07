import Foundation
import SwiftData

public struct ClipboardExternalDeps {
    let appRouter: AppRouter
    let modelContext: ModelContext
    
    init(appRouter: AppRouter, modelContext: ModelContext) {
        self.appRouter = appRouter
        self.modelContext = modelContext
    }
}
