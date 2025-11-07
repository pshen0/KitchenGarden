import SwiftUI

struct ThoughtBubbleView: View {
    private enum Constants {
        static let texts: [String] = ["⌘ 1-3 - pinned", "⌘ 4-8 - recent"]
        
        static let showDuration: TimeInterval = 1.6
        static let pauseDuration: TimeInterval = 2.0
        static let appearDelay: UInt64 = 200_000_000
        
        static let initialScale: CGFloat = 0.85
        static let visibleScale: CGFloat = 1.0
        static let hiddenScale: CGFloat = 0.92
        
        static let initialYOffset: CGFloat = -8
        static let visibleYOffset: CGFloat = 0
        
        static let bubbleCornerRadius: CGFloat = 30
        static let bubblePadding: CGFloat = 8
        static let bubbleShadowOpacity: Double = 0.12
        static let bubbleShadowRadius: CGFloat = 8
        static let bubbleShadowOffsetY: CGFloat = 4
        
        static let borderLineWidth: CGFloat = 1.0
        static let blurRadius: CGFloat = 0.6
        static let borderGradient = LinearGradient(
            colors: [
                Color.white.opacity(0.75),
                Color.white.opacity(0.15),
                Color.black.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    @State private var currentText: String = ""
    @State private var isVisible: Bool = false
    @State private var scale: CGFloat = Constants.initialScale
    @State private var yOffset: CGFloat = Constants.initialYOffset
    @State private var loopTask: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            if isVisible {
                content
                    .transition(.scale.combined(with: .opacity))
                    .scaleEffect(scale)
                    .offset(y: yOffset)
                    .zIndex(1)
            }
        }
        .onAppear { startLoop() }
        .onDisappear {
            loopTask?.cancel()
            loopTask = nil
        }
    }
    
    private var content: some View {
        HStack {
            Circle()
                .stroke(Constants.borderGradient, lineWidth: Constants.borderLineWidth)
                .blur(radius: Constants.blurRadius)
                .compositingGroup()
                .shadow(color: Color.white.opacity(0.08), radius: Constants.blurRadius, x: -1, y: -1)
                .frame(width: 10)
                .padding(.trailing, -30)
                .padding(.bottom, -100)
            
            Text(currentText)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: Constants.bubbleCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.bubbleCornerRadius, style: .continuous)
                        .stroke(Constants.borderGradient, lineWidth: Constants.borderLineWidth)
                        .blur(radius: Constants.blurRadius)
                        .compositingGroup()
                        .shadow(color: Color.white.opacity(0.08), radius: Constants.blurRadius, x: -1, y: -1)
                )
                .background(
                    RoundedRectangle(cornerRadius: Constants.bubbleCornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.02), lineWidth: 0.5)
                        .blendMode(.overlay)
                )
                .shadow(color: Color.black.opacity(Constants.bubbleShadowOpacity),
                        radius: Constants.bubbleShadowRadius,
                        x: 0, y: Constants.bubbleShadowOffsetY)
                .fixedSize()
                .padding(Constants.bubblePadding)
        }
    }
    
    private func startLoop() {
        loopTask?.cancel()
        loopTask = Task {
            try? await Task.sleep(nanoseconds: Constants.appearDelay)
            while !Task.isCancelled {
                let next = Constants.texts.randomElement() ?? Constants.texts[0]
                
                await MainActor.run {
                    currentText = next
                    withAnimation(.interpolatingSpring(stiffness: 220, damping: 20)) {
                        isVisible = true
                        scale = Constants.visibleScale
                        yOffset = Constants.visibleYOffset
                    }
                }

                try? await Task.sleep(nanoseconds: UInt64(Constants.showDuration * 1_000_000_000))
                
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.28)) {
                        isVisible = false
                        scale = Constants.hiddenScale
                        yOffset = Constants.initialYOffset
                    }
                }

                try? await Task.sleep(nanoseconds: UInt64(Constants.pauseDuration * 1_000_000_000))
            }
        }
    }
}
    
