import Foundation

public enum ClipboardItemType: Int, CaseIterable {
    case text, url, image, file
    
    public var icon: String {
        switch self {
        case .text: return "doc.text"
        case .url: return "link"
        case .image: return "photo"
        case .file: return "doc"
        }
    }
    
    public var displayName: String {
        switch self {
        case .text: return "Text"
        case .url: return "URL"
        case .image: return "Image"
        case .file: return "File"
        }
    }
}
