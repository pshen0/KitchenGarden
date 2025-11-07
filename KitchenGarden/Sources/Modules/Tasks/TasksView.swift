import SwiftUI
import SwiftData

struct TasksView<ViewModel: TasksViewModel>: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt) private var taskItems: [TaskItem]
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            TasksHeaderView()
                .environmentObject(viewModel as! TasksViewModelImpl)
            TasksBoardView(tasks: viewModel.filteredTasks, viewModel: viewModel as! TasksViewModelImpl)
        }
        .background(Colors.yellowBackground.ignoresSafeArea())
        .onChange(of: taskItems) { newItems in
            viewModel.tasks = newItems.map { TasksModel(id: $0.id, title: $0.title,
                                                        tags: $0.tags, priority: $0.priority,
                                                        deadline: $0.deadline, status: $0.status,
                                                        timeSpent: $0.timeSpent)}
        }
        .onAppear {
            viewModel.tasks = taskItems.map { TasksModel(id: $0.id, title: $0.title,
                                                         tags: $0.tags, priority: $0.priority,
                                                         deadline: $0.deadline, status: $0.status,
                                                         timeSpent: $0.timeSpent)}
        }
    }
}
