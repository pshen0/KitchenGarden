import SwiftUI

@MainActor
protocol PomodoroFactory {
    func makePomodoroScreen() ->  PomodoroView<PomodoroViewModelImpl>
}

final class PomodoroFactoryImpl: PomodoroFactory {
    
    // MARK: - Init
    
    init(externalDeps: PomodoroExternalDeps) {
        self.externalDeps = externalDeps
    }
    
    // MARK: - Public Methods
    
    func makePomodoroScreen() -> PomodoroView<PomodoroViewModelImpl> {
        let pomodoroView = PomodoroView(viewModel: sharedViewModel)
        return pomodoroView
    }
    
    // MARK: - Private Properties
    
    private let externalDeps: PomodoroExternalDeps

    private lazy var sharedRouter: PomodoroRouter = {
        PomodoroRouterImpl(appRouter: externalDeps.appRouter)
    }()

    private lazy var sharedInteractor: PomodoroInteractor = {
        PomodoroInteractorImpl()
    }()

    private lazy var sharedViewModel: PomodoroViewModelImpl = {
        PomodoroViewModelImpl(interactor: sharedInteractor, router: sharedRouter)
    }()
}
