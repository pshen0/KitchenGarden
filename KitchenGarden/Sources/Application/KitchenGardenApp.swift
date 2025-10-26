import SwiftUI
import SwiftData
import Combine

@main
struct KitchenGardenApp: App {
    @StateObject private var router: AppRouter
    @StateObject private var launcherHotkeyManager = LauncherHotkeyManager()
    
    private var diContainer: KitchenGardenDIContainer
    
    init() {
        let router = AppRouter()
        self._router = StateObject(wrappedValue: router)
        self.diContainer = KitchenGardenDIContainer(router: router)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView(diContainer: diContainer)
                .environmentObject(launcherHotkeyManager)
                .environmentObject(router)
            
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.hiddenTitleBar)
    }
}
