import SwiftUI
import SwiftData
import Combine

struct PomodoroView<ViewModel: PomodoroViewModel>: View {
    
    // MARK: - Internal Types
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack() {
            Color.green
        }
    }
}
