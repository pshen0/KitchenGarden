import SwiftUI

struct TasksView<ViewModel: TasksViewModel>: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            TasksHeaderView()
            TasksBoardView(tasks: viewModel.tasks, viewModel: viewModel as! TasksViewModelImpl)
        }
        .background(Colors.yellowBackground.ignoresSafeArea())
    }
}
