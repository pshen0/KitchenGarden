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
            Colors.redBackground
                .ignoresSafeArea()
            Image(.tomato)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}
