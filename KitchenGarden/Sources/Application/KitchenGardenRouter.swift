import SwiftUI
import Combine

enum AppRoute: Equatable, Identifiable {
    case pomodoro
    case clipboard
    case tasks
    
    var id: String {
        switch self {
        case .pomodoro: return "pomodoro"
        case .clipboard: return "clipboard"
        case .tasks: return "tasks"
        }
    }
}

import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var presentedSheet: AppRoute?
    @Published var isSidebarVisible: Bool = true
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func setRoot(_ route: AppRoute) {
        path = [route]
    }
    
    func pop() {
        _ = path.popLast()
    }
    
    func popAll() {
        path = []
    }
    
    func present(_ route: AppRoute) {
        presentedSheet = route
    }
    
    func dismiss() {
        presentedSheet = nil
    }
}
