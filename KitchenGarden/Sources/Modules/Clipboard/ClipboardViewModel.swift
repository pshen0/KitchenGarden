import SwiftUI
import Combine
import SwiftData

enum ClipboardConstants {
    static let maxItems = 100
    static let maxPinnedItems = 10
}

@MainActor
protocol ClipboardViewModel: ObservableObject {
    var clipboardItems: [ClipboardModel] { get }
    var filteredItems: [ClipboardModel] { get }
    var searchText: String { get set }
    
    func fetchClipboardHistory()
    func startMonitoring()
    func stopMonitoring()
    func copyItem(_ item: ClipboardModel)
    func pinItem(_ item: ClipboardModel)
    func deleteItem(_ item: ClipboardModel)
    func clearHistory()
}

@MainActor
final class ClipboardViewModelImpl: ClipboardViewModel {
    
    // MARK: - Internal Properties
    
    @Published var clipboardItems: [ClipboardModel] = []
    @Published var searchText: String = ""
    
    // MARK: - Computed Properties
    
    var filteredItems: [ClipboardModel] {
        if searchText.isEmpty {
            return clipboardItems
        }
        return clipboardItems.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Init
    
    init(interactor: ClipboardInteractor, router: ClipboardRouter, modelContext: ModelContext) {
        self.interactor = interactor
        self.router = router
        self.modelContext = modelContext
        fetchClipboardHistory()
        startMonitoring()
    }
    
    // MARK: - Public Methods
    
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
            
            let pinnedCount = self.clipboardItems.filter { $0.isPinned }.count
            let recentCount = self.clipboardItems.count - pinnedCount
            print("Fetched: \(self.clipboardItems.count) items (\(pinnedCount) pinned, \(recentCount) recent)")
            
        } catch {
            print("Failed to fetch clipboard history: \(error)")
            clipboardItems = []
        }
    }
    
    func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboardChanges()
        }
    }
    
    func stopMonitoring() {
    }
    
    func copyItem(_ item: ClipboardModel) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
    }
    
    func pinItem(_ item: ClipboardModel) {
        let pinnedOrder: Int?
        
        if !item.isPinned {
            pinnedOrder = 0
            shiftPinnedOrders(startingFrom: 0)
        } else {
            pinnedOrder = nil
            if let currentOrder = item.pinnedOrder {
                shiftPinnedOrders(startingFrom: currentOrder + 1, direction: .up)
            }
        }
        
        let updatedItem = ClipboardModel(
            id: item.id,
            content: item.content,
            timestamp: item.timestamp,
            type: item.type,
            isPinned: !item.isPinned,
            pinnedOrder: pinnedOrder
        )
        updateItem(updatedItem)
        
        if updatedItem.isPinned {
            do {
                try enforcePinnedLimit()
                fetchClipboardHistory()
            } catch {
                print("Failed to enforce pinned limit: \(error)")
            }
        } else {
            fetchClipboardHistory()
        }
    }
    
    func deleteItem(_ item: ClipboardModel) {
        do {
            let descriptor = FetchDescriptor<ClipboardItem>()
            let allItems = try modelContext.fetch(descriptor)
            
            if let clipboardItem = allItems.first(where: { $0.id == item.id }) {
                if clipboardItem.isPinned, let order = clipboardItem.pinnedOrder {
                    shiftPinnedOrders(startingFrom: order + 1, direction: .up)
                }
                
                modelContext.delete(clipboardItem)
                try modelContext.save()
                fetchClipboardHistory()
            }
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    
    func clearHistory() {
        do {
            let descriptor = FetchDescriptor<ClipboardItem>()
            let items = try modelContext.fetch(descriptor)
            for item in items {
                modelContext.delete(item)
            }
            try modelContext.save()
            fetchClipboardHistory()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func checkClipboardChanges() {
        if let newContent = interactor.getClipboardContent() {
            if let existingItem = findExistingItem(with: newContent.content) {
                let updatedModel = ClipboardModel(
                    id: existingItem.id,
                    content: existingItem.content,
                    timestamp: Date(),
                    type: existingItem.type,
                    isPinned: existingItem.isPinned,
                    pinnedOrder: existingItem.pinnedOrder
                )
                updateItem(updatedModel)
            } else {
                saveNewClipboardItem(content: newContent.content, type: newContent.type)
            }
        }
    }

    private func findExistingItem(with content: String) -> ClipboardItem? {
        do {
            let descriptor = FetchDescriptor<ClipboardItem>(
                predicate: #Predicate<ClipboardItem> { $0.content == content }
            )
            let existingItems = try modelContext.fetch(descriptor)
            return existingItems.first
        } catch {
            print("Failed to find existing item: \(error)")
            return nil
        }
    }
    
    private func saveNewClipboardItem(content: String, type: ClipboardItemType) {
        let newModel = ClipboardModel(content: content, type: type)
        let newItem = interactor.toDataModel(newModel)
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            try enforceMaxLimit()
            fetchClipboardHistory()
        } catch {
            print("Failed to save clipboard item: \(error)")
        }
    }
    
    private func enforceMaxLimit() throws {
        let descriptor = FetchDescriptor<ClipboardItem>(
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        let allItems = try modelContext.fetch(descriptor)
        
        if allItems.count > ClipboardConstants.maxItems {
            let itemsToDelete = Array(allItems.prefix(allItems.count - ClipboardConstants.maxItems))
            for item in itemsToDelete {
                modelContext.delete(item)
            }
            try modelContext.save()
            print("Deleted \(itemsToDelete.count) old items (limit: \(ClipboardConstants.maxItems))")
        }
    }
    
    private func enforcePinnedLimit() throws {
        let descriptor = FetchDescriptor<ClipboardItem>(
            predicate: #Predicate<ClipboardItem> { $0.isPinned },
            sortBy: [SortDescriptor(\.pinnedOrder, order: .reverse)]
        )
        let pinnedItems = try modelContext.fetch(descriptor)
        
        if pinnedItems.count > ClipboardConstants.maxPinnedItems {
            let itemsToUnpin = Array(pinnedItems.prefix(pinnedItems.count - ClipboardConstants.maxPinnedItems))
            for item in itemsToUnpin {
                item.isPinned = false
            }
            try modelContext.save()
            print("Unpinned \(itemsToUnpin.count) old pinned items")
        }
    }
    
    private func updateItem(_ item: ClipboardModel) {
        do {
            let descriptor = FetchDescriptor<ClipboardItem>()
            let allItems = try modelContext.fetch(descriptor)
            
            if let clipboardItem = allItems.first(where: { $0.id == item.id }) {
                clipboardItem.content = item.content
                clipboardItem.timestamp = item.timestamp
                clipboardItem.typeValue = item.type.rawValue
                clipboardItem.isPinned = item.isPinned
                clipboardItem.pinnedOrder = item.pinnedOrder
                
                try modelContext.save()
                fetchClipboardHistory()
            }
        } catch {
            print("Failed to update item: \(error)")
        }
    }
    
    private enum ShiftDirection {
        case up, down
    }

    private func shiftPinnedOrders(startingFrom index: Int, direction: ShiftDirection = .down) {
        do {
            let descriptor = FetchDescriptor<ClipboardItem>()
            let allItems = try modelContext.fetch(descriptor)
            let pinnedItems = allItems.filter { $0.isPinned && ($0.pinnedOrder ?? -1) >= index }
            
            for item in pinnedItems {
                if direction == .down {
                    item.pinnedOrder = (item.pinnedOrder ?? 0) + 1
                } else {
                    let newOrder = (item.pinnedOrder ?? 0) - 1
                    item.pinnedOrder = newOrder >= 0 ? newOrder : nil
                }
            }
            try modelContext.save()
        } catch {
            print("Failed to shift pinned orders: \(error)")
        }
    }
    
    // MARK: - Private Properties
    
    private let interactor: ClipboardInteractor
    private let router: ClipboardRouter
    private let modelContext: ModelContext
}
