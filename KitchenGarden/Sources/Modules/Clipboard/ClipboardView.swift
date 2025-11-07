import SwiftUI
import SwiftData
import Combine

struct ClipboardView<ViewModel: ClipboardViewModel>: View {
    
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var searchText: String = ""
    @State private var copiedItemId: UUID? = nil
    @State private var hoveredItemId: UUID? = nil
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Colors.greenBackground
                    .ignoresSafeArea()
                
                leftSide(geometry: geometry)
                    .frame(width: geometry.size.width * 0.20)
                    .padding(.leading, leadingPadding)
                    .padding(.top, 50)
                
                rightSide(geometry: geometry)
                    .frame(width: geometry.size.width * 0.6)
                    .padding(.trailing, 40)
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .ignoresSafeArea()
    }
    
    private var leadingPadding: CGFloat {
        let sidebarWidth: CGFloat = 190
        let safeAreaPadding: CGFloat = 90
        return router.isSidebarVisible ? (sidebarWidth + safeAreaPadding) : safeAreaPadding
    }
    
    private func leftSide(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Clipboard")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
                .padding(.bottom, 30)
            
            cucumberSection(geometry: geometry)
            
            Spacer()
            
            hotkeysSection(geometry: geometry)
        }
        .frame(width: geometry.size.width * 0.3)
        .padding(.horizontal, 10)
    }
    
    private func cucumberSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                    Images.LocalImages.cucumber
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                    ThoughtBubbleView()
                        .frame(maxWidth: 220)
                        .padding(.leading, -110)
                        .padding(.top, -50)
            }
        }
        .padding(.top, 50)
    }
    
    private func hotkeysSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HotkeyRow(key: "Tap on card", action: "Copy selected")
            HotkeyRow(key: "⌘ 1-3", action: "Copy 1-3 most recent pinned item")
            HotkeyRow(key: "⌘ 4-8", action: "Copy 4-8 most recent item")
        }
        .padding(.bottom, 50)
    }
    
    private func rightSide(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            searchField(geometry: geometry)
            
            clipboardList(geometry: geometry)
        }
        .frame(width: geometry.size.width * 0.5)
        .padding(.vertical, 30)
        .padding(.trailing, 40)
    }
    
    private func searchField(geometry: GeometryProxy) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Colors.greenAccent)
            
            TextField("Search clipboard history...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Colors.greenAccent)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Colors.greenAccent.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func clipboardList(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredItems.sorted {
                    if $0.isPinned != $1.isPinned {
                        return $0.isPinned
                    } else if $0.isPinned {
                        return ($0.pinnedOrder ?? Int.max) < ($1.pinnedOrder ?? Int.max)
                    } else {
                        return $0.timestamp > $1.timestamp
                    }
                }) { item in
                    clipboardItemRow(item: item)
                }
            }
        }
    }
    
    private func clipboardItemRow(item: ClipboardModel) -> some View {
        let isCopied = copiedItemId == item.id
        let isHovered = hoveredItemId == item.id
        
        let displayContent = item.content
            .replacingOccurrences(of: "\n", with: "↵")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.type.icon)
                .foregroundColor(Colors.greenAccent)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(displayContent)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(item.timeAgo)
                    .font(.caption)
                    .foregroundColor(Colors.greenAccent.opacity(0.7))
                
            }
            
            Spacer()
            
            if let hotkeyHint = hotkeyHint(for: item) {
                Text(hotkeyHint)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Colors.greenAccent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Colors.greenAccent.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Button(action: {
                viewModel.pinItem(item)
            }) {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                    .foregroundColor(item.isPinned ? Colors.greenAccent : Colors.greenAccent.opacity(0.5))
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                viewModel.deleteItem(item)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(Colors.greenAccent.opacity(0.5))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCopied ? Colors.greenAccent.opacity(0.1) :
                      (isHovered ? Colors.greenAccent.opacity(0.05) : Color.white.opacity(0.05)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovered ? Colors.greenAccent.opacity(0.4) : Colors.greenAccent.opacity(0.2), lineWidth: 1)
        )
        .onHover { hovering in
            hoveredItemId = hovering ? item.id : nil
        }
        .onTapGesture {
                viewModel.copyItem(item)
                copiedItemId = item.id
                        
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if copiedItemId == item.id {
                        copiedItemId = nil
                    }
                }
            }
    }
    
    private func hotkeyHint(for item: ClipboardModel) -> String? {
        guard let index = getItemIndex(item) else { return nil }
        
        if item.isPinned {
            // Для закрепленных: ⌘1, ⌘2, ⌘3
            guard index < 3 else { return nil }
            return "⌘\(index + 1)"
        } else {
            // Для недавних: ⌘4, ⌘5, ⌘6, ⌘7, ⌘8
            guard index < 5 else { return nil }
            return "⌘\(index + 4)"
        }
    }

    private func getItemIndex(_ item: ClipboardModel) -> Int? {
        let items = viewModel.filteredItems.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned
            } else if $0.isPinned {
                return ($0.pinnedOrder ?? Int.max) < ($1.pinnedOrder ?? Int.max)
            } else {
                return $0.timestamp > $1.timestamp
            }
        }
        
        let pinnedItems = items.filter { $0.isPinned }
        let unpinnedItems = items.filter { !$0.isPinned }
        
        if item.isPinned {
            return pinnedItems.firstIndex { $0.id == item.id }
        } else {
            return unpinnedItems.firstIndex { $0.id == item.id }
        }
    }
}



struct HotkeyRow: View {
    let key: String
    let action: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(key)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(Colors.greenAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Colors.greenAccent.opacity(0.2))
                .cornerRadius(4)
            
            Text(action)
                .font(.caption)
                .foregroundColor(.primary.opacity(0.8))
            
            Spacer()
        }
    }
}
