import Foundation
import SwiftData

@Model
final class ClipboardItem {
    var id: UUID
    var content: String
    var timestamp: Date
    var typeValue: Int
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
        self.typeValue = type.rawValue
        self.isPinned = isPinned
        self.pinnedOrder = pinnedOrder
    }
}

extension ClipboardItem {
    var type: ClipboardItemType {
        get { ClipboardItemType(rawValue: typeValue) ?? .text }
        set { typeValue = newValue.rawValue }
    }
}
