import SwiftUI

@MainActor
protocol PomodoroFactory {
    func makePomodoroScreen() ->  PomodoroView<PomodoroViewModelImpl>
}

struct PomodoroFactoryImpl: PomodoroFactory {
    
    // MARK: - Init
    
    init(externalDeps: PomodoroExternalDeps) {
        self.externalDeps = externalDeps
    }
    
    // MARK: - Public Methods
    
    func makePomodoroScreen() -> PomodoroView<PomodoroViewModelImpl> {
        let router = PomodoroRouterImpl(
            appRouter: externalDeps.appRouter
        )
        let interactor = PomodoroInteractorImpl()
        let viewModel = PomodoroViewModelImpl(interactor: interactor, router: router)
        let pomodoroView = PomodoroView(viewModel: viewModel)
        return pomodoroView
    }
    
    // MARK: - Private Properties
    
    private let externalDeps: PomodoroExternalDeps
}
