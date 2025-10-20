import SwiftUI
import Combine

@MainActor
protocol HomeViewModel: ObservableObject {

}

@MainActor
final class HomeViewModelImpl: HomeViewModel {
    
    // MARK: - Internal Properties

    
    // MARK: - Init
    
    init(interactor: HomeInteractor, router: HomeRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Public Methods

    
    // MARK: - Private Properties
    
    private let interactor: HomeInteractor
    private let router: HomeRouter
}

