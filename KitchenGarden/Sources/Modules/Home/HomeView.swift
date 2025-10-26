import SwiftUI
import SwiftData
import Combine

struct HomeView<ViewModel: HomeViewModel>: View {
    
    // MARK: - Internal Types
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack() {
            Colors.neutralBackground
                .ignoresSafeArea()
        }
    }
}
