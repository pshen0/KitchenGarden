import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    private var diContainer: KitchenGardenDIContainer
    
    init(diContainer: KitchenGardenDIContainer) {
        self.diContainer = diContainer
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(router: router)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            NavigationStack(path: $router.path) {
                diContainer.homeModuleFactory.makeHomeScreen()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .pomodoro:
                            Color.indigo
                        case .clipboard:
                            Color.mint
                        case .tasks:
                            Color.green
                        }
                    }
            }
        }
    }
}
