import SwiftUI
import Combine

@MainActor
protocol PomodoroViewModel: ObservableObject {

}

@MainActor
final class PomodoroViewModelImpl: PomodoroViewModel {
    
    // MARK: - Internal Properties

    
    // MARK: - Init
    
    init(interactor: PomodoroInteractor, router: PomodoroRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Public Methods

    
    // MARK: - Private Properties
    
    private let interactor: PomodoroInteractor
    private let router: PomodoroRouter
}

