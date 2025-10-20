import SwiftUI

@MainActor
protocol ClipboardFactory {
    func makeClipboardScreen() ->  ClipboardView<ClipboardViewModelImpl>
}

struct ClipboardFactoryImpl: ClipboardFactory {
    
    // MARK: - Init
    
    init(externalDeps: ClipboardExternalDeps) {
        self.externalDeps = externalDeps
    }
    
    // MARK: - Public Methods
    
    func makeClipboardScreen() -> ClipboardView<ClipboardViewModelImpl> {
        let router = ClipboardRouterImpl(
            appRouter: externalDeps.appRouter
        )
        let interactor = ClipboardInteractorImpl()
        let viewModel = ClipboardViewModelImpl(interactor: interactor, router: router)
        let сlipboardView = ClipboardView(viewModel: viewModel)
        return сlipboardView
    }
    
    // MARK: - Private Properties
    
    private let externalDeps: ClipboardExternalDeps
}
