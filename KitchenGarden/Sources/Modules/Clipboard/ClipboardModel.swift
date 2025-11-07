import Foundation

struct ClipboardModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var content: String
    var timestamp: Date
    var type: ClipboardItemType
    var isPinned: Bool
    var pinnedOrder: Int?
    
    init(id: UUID = UUID(),
         content: String,
         timestamp: Date = Date(),
         type: ClipboardItemType = .text,
         isPinned: Bool = false,
         pinnedOrder: Int? = nil) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.type = type
        self.isPinned = isPinned
        self.pinnedOrder = pinnedOrder
    }
    
    var preview: String {
        if content.count > 100 {
            return String(content.prefix(100)) + "..."
        }
        return content
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var canDisplay: Bool {
        switch type {
        case .text, .url:
            return true
        case .image, .file:
            return false
        }
    }
    
    var displayTitle: String {
        switch type {
        case .text: return "Text"
        case .url: return "URL"
        case .image: return "Image"
        case .file: return "File"
        }
    }
    
    static func == (lhs: ClipboardModel, rhs: ClipboardModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
