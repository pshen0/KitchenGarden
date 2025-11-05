import SwiftUI

struct TasksHeaderView: View {
    @EnvironmentObject var viewModel: TasksViewModelImpl
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Text("Board")
                        .font(.title)
                        .bold()
                    Images.LocalImages.corn
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 42, height: 42)
                }
                .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(Colors.yellowBackground)
            
            Rectangle()
                .fill(Colors.yellowSecondary)
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            HStack {
                Menu {
                    Button("All Priorities") {
                        viewModel.priorityFilter = nil
                    }
                    Button("No Priority") {
                        viewModel.priorityFilter = -1
                    }
                    Button("Low") {
                        viewModel.priorityFilter = 0
                    }
                    Button("Medium") {
                        viewModel.priorityFilter = 1
                    }
                    Button("High") {
                        viewModel.priorityFilter = 2
                    }
                } label: {
                    HStack {
                        Text(priorityFilterText)
                        Images.SystemImages.chevronDown
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Colors.yellowSecondary, lineWidth: 1)
                )
                .padding(.leading, 16)
                .padding(.top, 12)
                
                Spacer()
            }
        }
    }
    
    private var priorityFilterText: String {
            switch viewModel.priorityFilter {
            case nil: return "All Priorities"
            case -1: return "No Priority"
            case 0: return "Low"
            case 1: return "Medium"
            case 2: return "High"
            default: return "Priority"
            }
        }
}
