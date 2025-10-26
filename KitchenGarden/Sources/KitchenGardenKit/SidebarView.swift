import SwiftUI

struct SidebarView: View {
    @ObservedObject private var router: AppRouter
    
    init(router: AppRouter) {
        self.router = router
    }

    var body: some View {
        List {
            Text(Constants.appName)
                .font(.title2)
                .bold()
            
            SidebarButton(title: Constants.homeButton,
                          image: Image(.vegetables),
                          isSelected: router.path.isEmpty
            ) {
                router.popAll()
            }
            
            SidebarButton(title: Constants.clipboardButton,
                          image: Image(.cucumber),
                          isSelected: !router.path.isEmpty && router.path.last == .clipboard
            ) {
                router.setRoot(.clipboard)
            }
            
            SidebarButton(title: Constants.tasksButton,
                          image: Image(.corn),
                          isSelected: !router.path.isEmpty && router.path.last == .tasks
            ) {
                router.setRoot(.tasks)
            }
            
            SidebarButton(title: Constants.pomodoroButton,
                          image: Image(.tomato),
                          isSelected: !router.path.isEmpty && router.path.last == .pomodoro
            ) {
                router.setRoot(.pomodoro)
            }
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

#Preview {
    SidebarView(router: AppRouter())
}
