import SwiftUI

struct TaskCardView: View {
    let task: TasksModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.title)
                    .font(.body)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: {}) {
                    Images.SystemImages.ellipsis
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            
            Rectangle()
                .fill(Colors.yellowSecondary)
                .frame(height: 1)
            
            VStack(alignment: .leading, spacing: 8) {
                if !task.tags.isEmpty {
                    HStack(spacing: 6) {
                        Images.SystemImages.hashtag
                            .font(.caption)
                            .foregroundColor(Colors.yellowAccent)
                        Text(task.tags.joined(separator: ", "))
                            .font(.caption)
                    }
                }
                
                if let deadline = task.deadline {
                    HStack(spacing: 6) {
                        Images.SystemImages.calendar
                            .font(.caption)
                            .foregroundColor(Colors.yellowAccent)
                        Text(formatDate(deadline))
                            .font(.caption)
                    }
                }
                
                if let priority = task.priority {
                    HStack(spacing: 6) {
                        Images.SystemImages.flag
                            .font(.caption)
                            .foregroundColor(priorityColor)
                        Text(priorityText)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [Colors.yellowTask1, Colors.yellowTask2],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(12)
        .onDrag {
            NSItemProvider(object: task.id.uuidString as NSString)
        }
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case 0: return Colors.greenAccent
        case 1: return Colors.yellowAccent
        case 2: return Colors.redAccent
        default: return Colors.yellowSecondary
        }
    }
    
    private var priorityText: String {
        switch task.priority {
        case 0: return "Low"
        case 1: return "Medium"
        case 2: return "High"
        default: return ""
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
