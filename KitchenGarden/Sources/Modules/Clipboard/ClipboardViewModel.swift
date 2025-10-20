import SwiftUI
import Combine

@MainActor
protocol ClipboardViewModel: ObservableObject {

}

@MainActor
final class ClipboardViewModelImpl: ClipboardViewModel {
    
    // MARK: - Internal Properties

    
    // MARK: - Init
    
    init(interactor: ClipboardInteractor, router: ClipboardRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Public Methods

    
    // MARK: - Private Properties
    
    private let interactor: ClipboardInteractor
    private let router: ClipboardRouter
}

