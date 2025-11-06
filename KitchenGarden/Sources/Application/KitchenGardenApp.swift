import SwiftUI
import SwiftData
import AppKit


@main
struct KitchenGardenApp: App {
    @StateObject private var router: AppRouter
    private var diContainer: KitchenGardenDIContainer
    
    init() {
        let router = AppRouter()
        self._router = StateObject(wrappedValue: router)
        
        let modelContext = sharedModelContainer.mainContext
            
        self.diContainer = KitchenGardenDIContainer(router: router, modelContext: modelContext)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            TaskItem.self,
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
                .frame(minWidth: 1000, minHeight: 500)
                .environmentObject(router)
                .onAppear {
                    if let window = NSApplication.shared.windows.first , let screen = NSScreen.main {
                        window.isRestorable = false
                        let screenSize = screen.visibleFrame.size
                        window.setContentSize(screenSize)
                        window.center()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
        }
    }
}
