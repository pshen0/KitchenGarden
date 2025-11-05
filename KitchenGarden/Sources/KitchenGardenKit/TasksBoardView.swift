import SwiftUI

struct TasksBoardView: View {
    let tasks: [TaskItem]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                TaskColumnView(
                    title: "Created",
                    color: Colors.yellowSecondary,
                    tasks: tasks.filter { $0.status == .created },
                    columnStatus: .created
                )
                TaskColumnView(
                    title: "In Progress",
                    color: Colors.yellowSecondary,
                    tasks: tasks.filter { $0.status == .inProgress },
                    columnStatus: .inProgress
                )
                TaskColumnView(
                    title: "Completed",
                    color: Colors.yellowSecondary,
                    tasks: tasks.filter { $0.status == .completed },
                    columnStatus: .completed
                )
            }
            .padding()
        }
    }
}
