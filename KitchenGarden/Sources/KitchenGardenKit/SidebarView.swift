import SwiftUI

struct SidebarView: View {
    @ObservedObject private var router: AppRouter
    
    init(router: AppRouter) {
        self.router = router
    }

    var body: some View {
        List {
            Text(Constants.appName)
                .foregroundColor(.accentColor)
                .font(.title3)
                .bold()
            
            Button(action: {
                router.popAll()
            }) {
                HStack {
                    Image(.tomato)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                    Text(Constants.homeButton)
                    Spacer()
                }
                .padding()
            }
            .frame(width: 150, height: 40)
            .background(router.path.isEmpty ? Color.accentColor : .clear)
            .cornerRadius(10)
            
            Button(action: {
                router.setRoot(.clipboard)
            }) {
                HStack {
                    Image(.tomato)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                    Text(Constants.clipboardButton)
                    Spacer()
                }
                .padding()
            }
            .frame(width: 150, height: 40)
            .background(!router.path.isEmpty && router.path.last == .clipboard ? Color.accentColor : .clear)
            .cornerRadius(10)
            
            Button(action: {
                router.setRoot(.tasks)
            }) {
                HStack {
                    Image(.tomato)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                    Text(Constants.tasksButton)
                    Spacer()
                }
                .padding()
            }
            .frame(width: 150, height: 40)
            .background(!router.path.isEmpty && router.path.last == .tasks ? Color.accentColor : .clear)
            .cornerRadius(10)
            
            Button(action: {
                router.setRoot(.pomodoro)
            }) {
                HStack {
                    Image(.tomato)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                    Text(Constants.pomodoroButton)
                    Spacer()
                }
                .padding()
            }
            .frame(width: 150, height: 40)
            .background(!router.path.isEmpty && router.path.last == .pomodoro ? Color.accentColor : .clear)
            .cornerRadius(10)
        }
        .listStyle(.sidebar)
        .navigationTitle("Menu")
        .buttonStyle(PlainButtonStyle())
    }
    
    enum Constants {
        static let appName = "Kitchen Garden"
        static let homeButton = "Home"
        static let pomodoroButton = "Pomodoro"
        static let clipboardButton = "Clipboard"
        static let tasksButton = "Tasks"
    }
}
