import SwiftUI

struct TasksBoardView: View {
    let tasks: [TasksModel]
    let viewModel: TasksViewModelImpl
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                TaskColumnView(
                    title: "Created",
                    color: Colors.yellowSecondary,
                    tasks: tasks.filter { $0.status == .created },
                    columnStatus: .created,
                    viewModel: viewModel
                )
                TaskColumnView(
                    title: "In Progress",
                    color: Colors.yellowSecondary,
                    tasks: tasks.filter { $0.status == .inProgress },
                    columnStatus: .inProgress,
                    viewModel: viewModel
                )
                TaskColumnView(
                    title: "Completed",
                    color: Colors.yellowSecondary,
                    tasks: tasks.filter { $0.status == .completed },
                    columnStatus: .completed,
                    viewModel: viewModel
                )
            }
            .padding()
        }
    }
}
