import SwiftUI

struct TasksView<ViewModel: TasksViewModel>: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Верхняя панель с Board и сортировкой
            HStack {
                // Board с иконкой кукурузы
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
            
            // Горизонтальный разделитель на весь экран
            Rectangle()
                .fill(Colors.yellowSecondary)
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            HStack {
                // Кнопка сортировки по приоритетам
                Button(action: {}) {
                                    HStack {
                                        Text("Priority")
                                        Images.SystemImages.chevronDown
                                    }
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
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
            
            
            
            // Kanban доска
            HStack(alignment: .top, spacing: 16) {
                TaskColumnView(title: "Created", color: Colors.yellowSecondary)
                TaskColumnView(title: "In Progress", color: Colors.yellowSecondary)
                TaskColumnView(title: "Done", color: Colors.yellowSecondary)
            }
            .padding()
        }
        .background(Colors.yellowBackground.ignoresSafeArea())
    }
}
