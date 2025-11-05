import SwiftUI

struct TaskCardEditorView: View {
    @Binding var title: String
    @Binding var priority: Int
    @Binding var tags: String
    @Binding var deadline: Date
    @Binding var hasDeadline: Bool
    let columnStatus: TaskStatus
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTitleFocused: Bool
    @State private var editingTags = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Название задачи", text: $title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isTitleFocused)
                    .font(.body)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isTitleFocused = true
                        }
                    }
                
                Spacer()
                
                Button(action: onCancel) {
                    Images.SystemImages.ellipsis
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            
            Rectangle()
                .fill(Colors.yellowSecondary)
                .frame(height: 1)
            
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { cyclePriority() }) {
                    HStack(spacing: 6) {
                        Images.SystemImages.flag
                            .font(.caption)
                            .foregroundColor(priorityColor)
                        Text(priorityText)
                            .font(.caption)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: { editingTags.toggle() }) {
                    HStack(spacing: 6) {
                        Images.SystemImages.hashtag
                            .font(.caption)
                            .foregroundColor(Colors.yellowAccent)
                        
                        if editingTags {
                            TextField("Теги через запятую", text: $tags)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.caption)
                        } else {
                            Text(tags.isEmpty ? "Добавить теги" : tags)
                                .font(.caption)
                                .foregroundColor(tags.isEmpty ? .gray : .primary)
                        }
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: { hasDeadline.toggle() }) {
                    HStack(spacing: 6) {
                        Images.SystemImages.calendar
                            .font(.caption)
                            .foregroundColor(hasDeadline ? Colors.greenAccent : Colors.yellowAccent)
                        
                        Text(hasDeadline ? formatDate(deadline) : "Добавить дедлайн")
                            .font(.caption)
                            .foregroundColor(hasDeadline ? .primary : .gray)
                        
                        if hasDeadline {
                            Spacer()
                            
                            DatePicker("", selection: $deadline, in: Date()...)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .font(.caption)
                        } else {
                            Spacer()
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Button(action: onSave) {
                Text("Создать задачу")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Colors.yellowAccent, lineWidth: 1)
            )
            .disabled(title.isEmpty)
            .padding(.top, 4)
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
    }
    
    private func cyclePriority() {
        priority = (priority + 1) % 3
    }
    
    private var priorityText: String {
        switch priority {
        case 0: return "Low"
        case 1: return "Medium"
        case 2: return "High"
        default: return ""
        }
    }
    
    private var priorityColor: Color {
        switch priority {
        case 0: return Colors.greenAccent
        case 1: return Colors.yellowAccent
        case 2: return Colors.redAccent
        default: return Colors.yellowSecondary
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
