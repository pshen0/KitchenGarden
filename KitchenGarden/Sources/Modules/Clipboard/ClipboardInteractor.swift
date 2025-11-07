import Foundation
import AppKit
import SwiftData

protocol ClipboardInteractor {
    func toBusinessModel(_ clipboardItem: ClipboardItem) -> ClipboardModel
    func toDataModel(_ clipboardModel: ClipboardModel) -> ClipboardItem
    func getClipboardContent() -> (content: String, type: ClipboardItemType)?
}

final class ClipboardInteractorImpl: ClipboardInteractor {
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    
    init() {
        self.changeCount = pasteboard.changeCount
    }
    
    func toBusinessModel(_ clipboardItem: ClipboardItem) -> ClipboardModel {
        return ClipboardModel(
            id: clipboardItem.id,
            content: clipboardItem.content,
            timestamp: clipboardItem.timestamp,
            type: clipboardItem.type,
            isPinned: clipboardItem.isPinned,
            pinnedOrder: clipboardItem.pinnedOrder
        )
    }
    
    func toDataModel(_ clipboardModel: ClipboardModel) -> ClipboardItem {
        return ClipboardItem(
            id: clipboardModel.id,
            content: clipboardModel.content,
            timestamp: clipboardModel.timestamp,
            type: clipboardModel.type,
            isPinned: clipboardModel.isPinned,
            pinnedOrder: clipboardModel.pinnedOrder
        )
    }
    
    func getClipboardContent() -> (content: String, type: ClipboardItemType)? {
        guard pasteboard.changeCount != changeCount else { return nil }
        changeCount = pasteboard.changeCount
        
        if let string = pasteboard.string(forType: .string) {
            if string.hasPrefix("http://") || string.hasPrefix("https://") {
                return (string, .url)
            } else {
                return (string, .text)
            }
        }
        return nil
    }
}
