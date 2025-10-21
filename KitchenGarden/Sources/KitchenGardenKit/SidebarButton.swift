import SwiftUI

struct SidebarButton: View {
    let title: String
    let image: Image
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25)
                Text(title)
                Spacer()
            }
            .padding()
        }
        .frame(width: 150, height: 40)
        .background(isSelected ? Color.accentColor.opacity(0.3) : .clear)
        .cornerRadius(10)
    }
}
