import SwiftUI
import AppKit
import SwiftData

struct LauncherView: View {
    @State private var commandText = ""
    @State private var showingHelp = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Images.LocalImages.tomato
                    .resizable()
                    .scaledToFill()
                    .frame(height: 30)
                    .padding()
                
                TextField("Enter command...", text: $commandText)
                    .frame(width: 400, height: 50)
                    .cornerRadius(20)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20))
                    .padding()
                    .onSubmit {
                        handleCommand()
                    }
                    .onAppear {
                        commandText = ""
                        showingHelp = false // Close help sheet when launcher is opened
                        showError = false
                        errorMessage = nil
                    }
                
                Spacer()
            }
            .frame(width: 500, height: 50)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(20)
            
            if showError, let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .padding(.vertical, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
    }
    
    private func handleCommand() {
        let command = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // First try to parse as a task creation command
        if command.lowercased().starts(with: "task ") {
            if let taskInfo = LauncherCommand.parseTaskCommand(command) {
                // Validate task data
                if taskInfo.name.isEmpty {
                    showError(message: "Task name cannot be empty")
                    return
                }
                
                if taskInfo.date < Date() {
                    showError(message: "Task deadline must be in the future")
                    return
                }
                
                // Navigate to tasks and create new task
                router.navigate(to: .tasks)
                
                // Create task in the next run loop to ensure ModelContext is ready
                DispatchQueue.main.async {
                    createTask(info: taskInfo)
                }
                
                // Clear successful command
                commandText = ""
                activateMainWindow()
                return
            } else {
                showError(message: "Invalid task format. Use: task {name} {dd.MM.yyyy} {HH:mm}")
                return
            }
        }
        
        // If not a task command, try other commands
        if let launcherCommand = LauncherCommand(rawValue: command.lowercased()) {
            switch launcherCommand {
            case .home:
                router.popAll()
                commandText = ""
                activateMainWindow()
            case .tasks:
                router.navigate(to: .tasks)
                commandText = ""
                activateMainWindow()
            case .clipboard:
                router.navigate(to: .clipboard)
                commandText = ""
                activateMainWindow()
            case .pomodoro:
                router.navigate(to: .pomodoro)
                commandText = ""
                activateMainWindow()
            case .help:
                showingHelp = true
            case .task:
                showingHelp = true 
            }
            return
        }

        if !command.isEmpty {
            showError(message: "Unknown command. Type 'help' to see available commands")
        }
    }
    
    private func activateMainWindow() {
        if let mainWindow = NSApplication.shared.windows.first(where: { $0.title != "LauncherWindow" }) {
            mainWindow.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showError = false
                self.errorMessage = nil
            }
        }
    }
    
    private func createTask(info: LauncherCommand.TaskInfo) {
        let task = TaskItem(
            title: info.name,
            tags: [],
            priority: nil,
            deadline: info.date,
            status: .created,
            timeSpent: 0
        )
        
        modelContext.insert(task)
    }
}
