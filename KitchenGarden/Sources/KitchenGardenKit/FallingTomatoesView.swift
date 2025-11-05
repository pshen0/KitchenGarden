import SwiftUI

struct FallingTomato: Identifiable {
    let id = UUID()
    let x: CGFloat
    let phaseOffset: TimeInterval
    let initialRotation: Double
    let rotationDirection: Double
    let rotationSpeed: Double
}

struct TomatoSpec {
    let xFraction: CGFloat
    let yProgress: Double
}

struct FallingTomatoesView: View {
    let count: Int
    let tomatoSizeFraction: CGFloat
    let fallDuration: TimeInterval
    let horizontalJitter: CGFloat
    let specs: [TomatoSpec] = [
        TomatoSpec(xFraction: 0, yProgress: 0),
        TomatoSpec(xFraction: 0.19, yProgress: 0.5),
        TomatoSpec(xFraction: 0.3, yProgress: 0.2),
        TomatoSpec(xFraction: 0.18, yProgress: 0.9),
        TomatoSpec(xFraction: 0.1, yProgress: 0.65),
        TomatoSpec(xFraction: 0.68, yProgress: 0.75),
        TomatoSpec(xFraction: 0.85, yProgress: 0.1),
        TomatoSpec(xFraction: 0.75, yProgress: 0.35),
        TomatoSpec(xFraction: 0.9, yProgress: 0.8),
    ]

    @State private var tomatoes: [FallingTomato] = []
    @State private var lastWidth: CGFloat = 0
    @State private var lastHeight: CGFloat = 0

    init(
        count: Int = 30,
        tomatoSizeFraction: CGFloat = 0.5,
        fallDuration: TimeInterval = 20.0,
        horizontalJitter: CGFloat = 0
    ) {
        self.count = count
        self.tomatoSizeFraction = tomatoSizeFraction
        self.fallDuration = fallDuration
        self.horizontalJitter = horizontalJitter
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let tomatoSize: CGFloat = 100

            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    ForEach(tomatoes) { tomato in
                        let progress = normalizedProgress(now: now, phase: tomato.phaseOffset)
                        let y = yPosition(progress: progress, height: height, tomatoSize: tomatoSize)
                        let rotationDelta = now * 360 * tomato.rotationSpeed * tomato.rotationDirection
                        let rawAngle = tomato.initialRotation + rotationDelta
                        let rotationAngle = ((rawAngle.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)

                        Images.LocalImages.tomato
                            .resizable()
                            .scaledToFill()
                            .frame(width: tomatoSize, height: tomatoSize)
                            .opacity(0.6)
                            .rotationEffect(.degrees(rotationAngle))
                            .position(x: tomato.x, y: y)
                    }
                }
                .onAppear {
                    tomatoes = generateTomatoes(from: specs, width: width, height: height, tomatoSize: tomatoSize)
                    lastWidth = width
                    lastHeight = height
                }
            }
        }
        .clipped()
    }

    private func generateTomatoes(from specs: [TomatoSpec], width: CGFloat, height: CGFloat, tomatoSize: CGFloat) -> [FallingTomato] {
        let minAxisGap: CGFloat = 3
        let minX = tomatoSize / 2
        let maxX = max(minX, width - tomatoSize / 2)

        var result: [FallingTomato] = []
        var usedXs: [CGFloat] = []
        var usedProgresses: [Double] = []

        for i in [-1.0, 0.0, 1.0] {
            for spec in specs.prefix(max(0, specs.count)) {
                let clampedXFraction = spec.xFraction + i
                let clampedProgress = max(0.0, min(0.999999, spec.yProgress))

                var x = minX + clampedXFraction * (maxX - minX)
                if let tooClose = usedXs.first(where: { abs($0 - x) < minAxisGap }) {
                    x = min(maxX, max(minX, tooClose + (x >= tooClose ? minAxisGap : -minAxisGap)))
                }

                var p = clampedProgress
                if let tooCloseP = usedProgresses.first(where: { abs($0 - p) < Double(minAxisGap) / Double(max(height, 1)) }) {
                    let pixelToProgress = Double(minAxisGap / max(height + tomatoSize * 2, 1))
                    p = min(0.999999, max(0.0, tooCloseP + (p >= tooCloseP ? pixelToProgress : -pixelToProgress)))
                }

                usedXs.append(x)
                usedProgresses.append(p)

                let phase = p * fallDuration
                let initialRotation = Double.random(in: 0...360)
                let rotationDirection = Double.random(in: 0...1) < 0.5 ? 1.0 : -1.0
                let rotationSpeed = Double.random(in: 0.1...0.5)
                
                result.append(FallingTomato(
                    x: x,
                    phaseOffset: phase,
                    initialRotation: initialRotation,
                    rotationDirection: rotationDirection,
                    rotationSpeed: rotationSpeed
                ))
            }
        }

        return result
    }


    private func normalizedProgress(now: TimeInterval, phase: TimeInterval) -> Double {
        let t = (now + phase).truncatingRemainder(dividingBy: fallDuration)
        return t / fallDuration
    }

    private func yPosition(progress: Double, height: CGFloat, tomatoSize: CGFloat) -> CGFloat {
        let start = -tomatoSize
        let end = height + tomatoSize
        return CGFloat(start + (end - start) * progress)
    }
}
