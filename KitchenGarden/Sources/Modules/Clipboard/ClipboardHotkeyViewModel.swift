import SwiftUI
import SwiftData

@MainActor
final class ClipboardHotkeyViewModel {
    private let interactor: ClipboardInteractor
    private let modelContext: ModelContext
    private var clipboardItems: [ClipboardModel] = []
    
    init(interactor: ClipboardInteractor, modelContext: ModelContext) {
        self.interactor = interactor
        self.modelContext = modelContext
        fetchClipboardHistory()
    }
    
    func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboardChanges()
        }
    }
    
    func fetchClipboardHistory() {
        do {
            let descriptor = FetchDescriptor<ClipboardItem>()
            let clipboardItems = try modelContext.fetch(descriptor)
            
            let sortedItems = clipboardItems.sorted {
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned
                } else if $0.isPinned {
                    return ($0.pinnedOrder ?? Int.max) < ($1.pinnedOrder ?? Int.max)
                } else {
                    return $0.timestamp > $1.timestamp
                }
            }
            
            self.clipboardItems = sortedItems.map { interactor.toBusinessModel($0) }
            
            let pinnedItems = self.clipboardItems.filter { $0.isPinned }
            print("HotkeyVM: \(self.clipboardItems.count) items (\(pinnedItems.count) pinned)")
            for (i, item) in pinnedItems.enumerated() {
                print("[\(i)] order: \(item.pinnedOrder ?? -1) - '\(item.preview)'")
            }
            
        } catch {
            print("Failed to fetch clipboard history: \(error)")
            clipboardItems = []
        }
    }
    
    func getPinnedItem(at index: Int) -> ClipboardModel? {
        let pinnedItems = clipboardItems.filter { $0.isPinned }
        
        guard index >= 0 && index < min(3, pinnedItems.count) else { return nil }
        return pinnedItems[index]
    }
    
    func getRecentItem(at index: Int) -> ClipboardModel? {
        let recentItems = clipboardItems.filter { !$0.isPinned }
        
        guard index >= 0 && index < min(5, recentItems.count) else { return nil }
        return recentItems[index]
    }
    
    func copyItem(_ item: ClipboardModel) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
    }
    
    private func checkClipboardChanges() {
        if let newContent = interactor.getClipboardContent() {
            let isDuplicate = clipboardItems.contains { $0.content == newContent.content }
            if !isDuplicate {
                saveNewClipboardItem(content: newContent.content, type: newContent.type)
            }
        }
    }
    
    private func saveNewClipboardItem(content: String, type: ClipboardItemType) {
        let newModel = ClipboardModel(content: content, type: type)
        let newItem = interactor.toDataModel(newModel)
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            fetchClipboardHistory()
        } catch {
            print("Failed to save clipboard item: \(error)")
        }
    }
}
