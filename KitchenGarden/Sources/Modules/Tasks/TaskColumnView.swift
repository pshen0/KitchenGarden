import SwiftUI

struct TaskColumnView: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    statusIconView
                    Text(title)
                        .font(.title3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Colors.yellowStroke, lineWidth: 1)
                )
                
                Spacer()
                
                Button(action: {}) {
                    Images.SystemImages.plus
                        .font(.title2)
                        .foregroundColor(Colors.yellowStroke)
                }
                .buttonStyle(.plain)
            }
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    // Временно добавляем тестовую карточку
                    TaskCardView(task: testTask)
                    TaskCardView(task: testTask)
                    TaskCardView(task: testTask)
                }
            }
            .frame(minHeight: 200)
        }
        .frame(width: 280)
        .padding()
        .background(Colors.yellowSecondary)
        .cornerRadius(12)
    }
    
    private var statusIconView: some View {
        Group {
            switch title {
            case "Created":
                Image(systemName: "circle")
                    .foregroundColor(.white)
            case "In Progress":
                ZStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(Colors.yellowAccent)
                }
            case "Done":
                Image(systemName: "circle.fill")
                    .foregroundColor(Colors.greenAccent)
            default:
                Image(systemName: "circle")
                    .foregroundColor(.white)
            }
        }
        .font(.title3)
    }
}

private var testTask: TaskItem {
    TaskItem(
        title: "Add new homework",
        tags: ["HSE"],
        priority: 0,
        deadline: Date().addingTimeInterval(86400),
        status: .created,
        timeSpent: 0
    )
}
