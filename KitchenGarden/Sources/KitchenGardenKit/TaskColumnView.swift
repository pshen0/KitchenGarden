import SwiftUI
import Combine
internal import UniformTypeIdentifiers

struct TaskColumnView: View {
    let title: String
    let color: Color
    let tasks: [TasksModel]
    let columnStatus: TaskStatus
    let viewModel: TasksViewModelImpl
    
    
    @State private var showingQuickAdd = false
    @State private var newTaskTitle = ""
    @State private var selectedPriority: Int? = nil
    @State private var newTaskTags = ""
    @State private var newTaskDeadline: Date = Date()
    @State private var hasDeadline = false
    
    @State private var editingTask: TasksModel? = nil
    @State private var showingEdit = false
    
    
    init(title: String, color: Color, tasks: [TasksModel], columnStatus: TaskStatus, viewModel : TasksViewModelImpl) {
        self.title = title
        self.color = color
        self.tasks = tasks
        self.columnStatus = columnStatus
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    if showingQuickAdd {
                        TaskCardEditorView(
                            title: $newTaskTitle,
                            priority: $selectedPriority,
                            tags: $newTaskTags,
                            deadline: $newTaskDeadline,
                            hasDeadline: $hasDeadline,
                            columnStatus: columnStatus,
                            mode: .create,
                            onSave: saveTask,
                            onCancel: {
                                showingQuickAdd = false
                                resetEditor()
                            }
                        )
                    }
                    
                    if showingEdit {
                        TaskCardEditorView(
                            title: $newTaskTitle,
                            priority: $selectedPriority,
                            tags: $newTaskTags,
                            deadline: $newTaskDeadline,
                            hasDeadline: $hasDeadline,
                            columnStatus: columnStatus,
                            mode: .edit,
                            onSave: updateTask,
                            onCancel: {
                                showingEdit = false
                                resetEditor()
                            }
                        )
                    }
                    
                    ForEach(tasks) { task in
                        if editingTask?.id != task.id {
                            TaskCardView(
                                task: task,
                                onEdit: {
                                    editTask(task)
                                },
                                onDelete: {
                                    deleteTask(task)
                                }
                            )
                        }
                    }
                }
            }
            .frame(minHeight: 200)
        }
        .frame(width: 320)
        .padding()
        .background(Colors.yellowSecondary)
        .cornerRadius(12)
        .onDrop(of: [.text], isTargeted: nil) { providers in
            handleDrop(providers: providers)
        }
    }
    
    private func editTask(_ task: TasksModel) {
        editingTask = task
        newTaskTitle = task.title
        selectedPriority = task.priority
        newTaskTags = task.tags.joined(separator: ", ")
        newTaskDeadline = task.deadline ?? Date()
        hasDeadline = task.deadline != nil
        showingEdit = true
    }
    
    private func updateTask() {
        guard let task = editingTask else { return }
        
        let tags = newTaskTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let updatedTask = TasksModel(
            id: task.id,
            title: newTaskTitle,
            tags: tags,
            priority: selectedPriority,
            deadline: hasDeadline ? newTaskDeadline : nil,
            status: task.status,
            timeSpent: task.timeSpent
        )
        
        viewModel.updateTask(updatedTask)
        
        showingEdit = false
        resetEditor()
        editingTask = nil
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        var success = false
        
        provider.loadObject(ofClass: NSString.self) { reading, error in
            guard let taskIDString = reading as? String,
                  let taskID = UUID(uuidString: taskIDString) else { return }
            
            DispatchQueue.main.async {
                if let task = viewModel.tasks.first(where: { $0.id == taskID }) {
                    let updatedTask = TasksModel(
                        id: task.id,
                        title: task.title,
                        tags: task.tags,
                        priority: task.priority,
                        deadline: task.deadline,
                        status: self.columnStatus,
                        timeSpent: task.timeSpent
                    )
                    
                    self.viewModel.updateTask(updatedTask)
                    success = true
                }
            }
        }
        
        return success
    }
    
    private func deleteTask(_ task: TasksModel) {
        viewModel.deleteTask(task)
        print("Удаляем задачу: \(task.title)")
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                statusIconView
                Text(title)
                    .font(.title3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Colors.yellowStroke, lineWidth: 1)
            )
            
            Spacer()
            
            Button(action: {
                showingQuickAdd = true
            }) {
                Images.SystemImages.plus
                    .font(.title2)
                    .foregroundColor(Colors.yellowStroke)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(showingQuickAdd)
        }
    }
    
    private func saveTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let tags = newTaskTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let task = TasksModel(
            title: newTaskTitle,
            tags: tags,
            priority: selectedPriority,
            deadline: hasDeadline ? newTaskDeadline : nil,
            status: columnStatus
        )
        
        viewModel.addTask(task)  
        
        resetEditor()
        showingQuickAdd = false
    }
    
    private func resetEditor() {
        newTaskTitle = ""
        selectedPriority = nil
        newTaskTags = ""
        hasDeadline = false
        newTaskDeadline = Date()
    }
    
    private var statusIconView: some View {
        Group {
            switch columnStatus {
            case .created:
                Image(systemName: "circle")
                    .foregroundColor(.white)
            case .inProgress:
                ZStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(Colors.yellowAccent)
                }
            case .completed:
                Image(systemName: "circle.fill")
                    .foregroundColor(Colors.greenAccent)
            }
        }
        .font(.title3)
    }
}
