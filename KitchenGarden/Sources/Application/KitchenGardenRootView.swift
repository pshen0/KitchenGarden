import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    private var diContainer: KitchenGardenDIContainer
    
    init(diContainer: KitchenGardenDIContainer) {
        self.diContainer = diContainer
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(router: router)
                .navigationSplitViewColumnWidth(min: 180, ideal: 180)
        } detail: {
            NavigationStack(path: $router.path) {
                diContainer.homeModuleFactory.makeHomeScreen()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .pomodoro:
                            diContainer.pomodoroModuleFactory.makePomodoroScreen()
                        case .clipboard:
                            diContainer.clipboardModuleFactory.makeClipboardScreen()
                        case .tasks:
                            diContainer.tasksModuleFactory.makeTasksScreen()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            columnVisibility = .doubleColumn
            router.isSidebarVisible = columnVisibility != .detailOnly
        }
        .onChange(of: columnVisibility) { newValue in
            router.isSidebarVisible = newValue != .detailOnly
        }
    }
}
