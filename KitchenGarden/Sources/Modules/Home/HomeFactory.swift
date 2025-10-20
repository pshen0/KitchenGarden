import SwiftUI

@MainActor
protocol HomeFactory {
    func makeHomeScreen() ->  HomeView<HomeViewModelImpl>
}

struct HomeFactoryImpl: HomeFactory {
    
    // MARK: - Init
    
    init(externalDeps: HomeExternalDeps) {
        self.externalDeps = externalDeps
    }
    
    // MARK: - Public Methods
    
    func makeHomeScreen() -> HomeView<HomeViewModelImpl> {
        let router = HomeRouterImpl(
            appRouter: externalDeps.appRouter
        )
        let interactor = HomeInteractorImpl()
        let viewModel = HomeViewModelImpl(interactor: interactor, router: router)
        let homeView = HomeView(viewModel: viewModel)
        return homeView
    }
    
    // MARK: - Private Properties
    
    private let externalDeps: HomeExternalDeps
}
