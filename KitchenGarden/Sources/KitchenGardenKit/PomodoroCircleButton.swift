import SwiftUI

struct PomodoroCircleButton: View {
    let image: Image
    var isSFSymbol: Bool = true
    var buttonSize: CGFloat? = nil
    var iconSize: CGFloat? = nil
    let action: () -> Void
    
    private var calculatedButtonSize: CGFloat {
        buttonSize ?? 70
    }
    
    private var calculatedIconSize: CGFloat {
        if let iconSize = iconSize {
            return iconSize
        }
        return isSFSymbol ? 30 : 50
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Colors.redSecondary)
                    .frame(width: calculatedButtonSize, height: calculatedButtonSize)
                
                if isSFSymbol {
                    image
                        .resizable()
                        .renderingMode(.template)
                        .symbolRenderingMode(.monochrome)
                        .scaledToFit()
                        .foregroundColor(Colors.redText)
                        .frame(width: calculatedIconSize, height: calculatedIconSize)
                } else {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: calculatedIconSize, height: calculatedIconSize)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}
