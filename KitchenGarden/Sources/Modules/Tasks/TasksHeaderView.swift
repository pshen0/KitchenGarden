import SwiftUI

struct TasksHeaderView: View {
    var body: some View {
        HStack {
            Text("Задачи")
                .font(.title2)
                .bold()
            
            Spacer()
            
            Text("Все приоритеты")
                .foregroundColor(.gray)
            
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Colors.yellowAccent)
            }
        }
        .padding()
        .background(Colors.yellowBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Colors.yellowBackground),
            alignment: .bottom
        )
    }
}
