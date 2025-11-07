import SwiftUI

struct PomodoroSettingsSidebarView<ViewModel: PomodoroViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            List {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Name")
                        .font(.headline)
                    TextField("Enter task name", text: Binding(
                        get: { viewModel.taskTitle },
                        set: { newValue in
                            if newValue.count <= 20 {
                                viewModel.taskTitle = newValue
                            } else {
                                viewModel.taskTitle = String(newValue.prefix(20))
                            }
                        }
                    ))
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
                    Text("\(viewModel.taskTitle.count)/20")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Work Sessions")
                        .font(.headline)
                    StepperView(
                        value: $viewModel.totalWorkSessions,
                        range: 2...10,
                        suffix: " sessions"
                    )
                }
                .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Work Duration")
                        .font(.headline)
                    StepperView(
                        value: Binding(
                            get: { Int(viewModel.workDuration / 60) },
                            set: { viewModel.workDuration = TimeInterval($0 * 60) }
                        ),
                        range: 1...60,
                        suffix: " min"
                    )
                }
                .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Break Duration")
                        .font(.headline)
                    StepperView(
                        value: Binding(
                            get: { Int(viewModel.breakDuration / 60) },
                            set: { viewModel.breakDuration = TimeInterval($0 * 60) }
                        ),
                        range: 1...60,
                        suffix: " min"
                    )
                }
                .padding(.vertical, 8)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .buttonStyle(PlainButtonStyle())
            .frame(width: 250)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .transition(.move(edge: .trailing))
        }
    }
}

struct StepperView: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    var suffix: String = ""
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if value > range.lowerBound {
                    value -= 1
                }
            }) {
                Image(systemName: "minus")
                    .foregroundColor(value > range.lowerBound ? .primary : .secondary)
                    .font(.body)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(value <= range.lowerBound)
            
            Text("\(value)\(suffix)")
                .foregroundColor(.primary)
                .frame(minWidth: 80)
            
            Button(action: {
                if value < range.upperBound {
                    value += 1
                }
            }) {
                Image(systemName: "plus")
                    .foregroundColor(value < range.upperBound ? .primary : .secondary)
                    .font(.body)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(value >= range.upperBound)
        }
        .frame(maxWidth: .infinity, minHeight: 32)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}
