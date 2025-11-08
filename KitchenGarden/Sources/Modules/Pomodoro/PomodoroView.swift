import SwiftUI
import SwiftData
import Combine

struct PomodoroView<ViewModel: PomodoroViewModel>: View {
    
    // MARK: - Internal Types
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var isSettingsSidebarVisible: Bool = true
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                Colors.redBackground
                    .ignoresSafeArea()
                if viewModel.isPomodoroStarted && viewModel.isFallingTomatoesEnabled {
                    FallingTomatoesView(tomatoSizeFraction: 0.17)
                }
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Spacer()
                        if !viewModel.isPomodoroStarted {
                            settingsButton(geometry: geometry)
                        } else {
                            leadingButtons(geometry: geometry, isPomodoroStarted: viewModel.isPomodoroStarted)
                        }
                    }
                    .frame(height: min(geometry.size.width * 0.05, geometry.size.height * 0.08) * 2 + geometry.size.height * 0.02)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, geometry.size.height * 0.07)
                    .padding(.trailing, 10)
                    
                    Spacer()
                    
                    taskTitle(geometry: geometry)
                        .padding(.top, -geometry.size.height * 0.2)

                    Spacer()
                    
                    pomodoroTimer(geometry: geometry)
                        .padding(.bottom, geometry.size.height * 0.1)
                    
                    bottomButtons(geometry: geometry, isPomodoroStarted: viewModel.isPomodoroStarted)
                    Spacer(minLength: geometry.size.height * 0.02)
                }

                HStack {
                    if !viewModel.isPomodoroStarted {
                        PomodoroSettingsSidebarView(
                            viewModel: viewModel,
                            isVisible: $isSettingsSidebarVisible
                        )
                        .padding(.leading, leadingPaddingForSettings)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: router.isSidebarVisible)
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
            .onChange(of: viewModel.isPomodoroStarted) { newValue in
                if newValue && isSettingsSidebarVisible {
                    withAnimation {
                        isSettingsSidebarVisible = false
                    }
                }
            }
        }
    }
    
    func settingsButton(geometry: GeometryProxy) -> some View {
        let buttonSize = min(geometry.size.width * 0.05, geometry.size.height * 0.08)
        let iconSize = buttonSize * 0.7
        
        return VStack(spacing: geometry.size.height * 0.02) {
            PomodoroCircleButton(
                image: Images.LocalImages.gearshape,
                isSFSymbol: false,
                buttonSize: buttonSize,
                iconSize: iconSize
            ) {
                isSettingsSidebarVisible.toggle()
            }
            Spacer()
                .frame(height: buttonSize)
        }
    }
    
    func leadingButtons(geometry: GeometryProxy, isPomodoroStarted: Bool) -> some View {
        let buttonSize = min(geometry.size.width * 0.05, geometry.size.height * 0.08)
        let iconSize = buttonSize * 0.7
        let sidebarWidth: CGFloat = 190
        let safeAreaPadding: CGFloat = 10
        let leadingPadding: CGFloat = router.isSidebarVisible ? (sidebarWidth + safeAreaPadding) : safeAreaPadding
        
        return VStack(spacing: geometry.size.height * 0.02) {
            PomodoroCircleButton(
                image: viewModel.isFocusModeEnabled ? Images.LocalImages.moonSymbolSlash : Images.LocalImages.moonSymbol,
                isSFSymbol: false,
                buttonSize: buttonSize,
                iconSize: iconSize
            ) {
                viewModel.toggleFocusMode()
            }
            PomodoroCircleButton(
                image: viewModel.isFallingTomatoesEnabled ? Images.LocalImages.tomatoSymbolSlash : Images.LocalImages.tomatoSymbol,
                isSFSymbol: false,
                buttonSize: buttonSize,
                iconSize: iconSize
            ) {
                viewModel.isFallingTomatoesEnabled.toggle()
            }
        }
        .padding(.leading, leadingPadding)
        .opacity(isPomodoroStarted ? 1 : 0)
        .disabled(!isPomodoroStarted)
        .allowsHitTesting(isPomodoroStarted)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: router.isSidebarVisible)
    }
    
    func taskTitle(geometry: GeometryProxy) -> some View {
        let width = min(geometry.size.width * 0.7, 560)
        let height = geometry.size.height * 0.08
        let fontSize = min(geometry.size.width * 0.03, geometry.size.height * 0.03)
        let cornerRadius = height * 0.5
        
        return Text(viewModel.isPomodoroStarted ? viewModel.taskTitle: "Get started with pomodoro!")
            .foregroundColor(.redText)
            .bold()
            .font(.system(size: fontSize))
            .frame(width: width, height: height)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke()
                    .foregroundColor(.redText)
            }
    }
    
    func bottomButtons(geometry: GeometryProxy, isPomodoroStarted: Bool) -> some View {
        let buttonSize = min(geometry.size.width * 0.08, geometry.size.height * 0.1)
        let fontSize = min(geometry.size.width * 0.03, geometry.size.height * 0.03)
        let iconSize = buttonSize * 0.43
        
        return Group {
            if isPomodoroStarted {
                HStack(spacing: geometry.size.width * 0.03) {
                    PomodoroCircleButton(
                        image: Images.SystemImages.stop,
                        buttonSize: buttonSize,
                        iconSize: iconSize
                    ) {
                        viewModel.resetTimer()
                    }
                    .padding()
                    PomodoroCircleButton(
                        image: viewModel.isRunning ? Images.SystemImages.pause : Images.SystemImages.play,
                        buttonSize: buttonSize,
                        iconSize: iconSize
                    ) {
                        if viewModel.isRunning { viewModel.pauseTimer() } else { viewModel.startTimer() }
                    }
                    .padding()
                    PomodoroCircleButton(
                        image: Images.SystemImages.forwardEnd,
                        buttonSize: buttonSize,
                        iconSize: iconSize
                    ) {
                        viewModel.completeWorkSession()
                    }
                    .padding()
                }
            } else {
                Button(action:  {
                    viewModel.startTimer()
                }) {
                    Text("START!")
                        .bold()
                        .font(.system(size: fontSize))
                        .foregroundColor(Colors.redText)
                        .frame(width: buttonSize * 3, height: buttonSize)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .fill(Colors.redSecondary)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func pomodoroTimer(geometry: GeometryProxy) -> some View {
        let timerSize = min(geometry.size.width * 0.45, geometry.size.height * 0.45)
        let circleLineWidth = timerSize * 0.055
        let tomatoImageSize = timerSize * 0.7
        let timeFontSize = timerSize * 0.17
        let sessionFontSize = timerSize * 0.055
        let focusFontSize = timerSize * 0.05
        let timeTopPadding = timerSize * 0.22
        
        return Group {
            if viewModel.isPomodoroStarted {
                ZStack {
                    Circle()
                        .stroke(Colors.redSecondary, lineWidth: circleLineWidth)
                    
                    Circle()
                        .trim(from: 0.0, to: progressValue)
                        .stroke(
                            Colors.redAccent,
                            style: StrokeStyle(lineWidth: circleLineWidth)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack {
                        ZStack {
                            Images.LocalImages.tomatoTimer
                                .resizable()
                                .scaledToFit()
                                .frame(width: tomatoImageSize)
                            VStack {
                                Text(formattedRemainingTime)
                                    .bold()
                                    .font(.system(size: timeFontSize))
                                    .foregroundColor(Colors.pinkAccent)
                                    .padding(.top, timeTopPadding)
                                Text("\(viewModel.completedWorkSessions)/\(viewModel.totalWorkSessions)")
                                    .font(.system(size: sessionFontSize))
                                    .foregroundColor(Colors.pinkAccent)
                            }
                        }
                        Text(viewModel.isBreakPeriod ? "Time to take a break" : "Stay focus!")
                            .font(.system(size: focusFontSize))
                            .foregroundColor(Colors.redText)
                    }
                }
                .frame(width: timerSize, height: timerSize)
            } else {
                ZStack {
                    Circle()
                        .stroke(Colors.redSecondary, lineWidth: circleLineWidth)
                    Images.LocalImages.tomato
                        .resizable()
                        .scaledToFit()
                        .frame(width: tomatoImageSize)
                }
                .frame(width: timerSize, height: timerSize)
            }
        }
    }
    
    private var progressValue: Double {
        let total = viewModel.isBreakPeriod ? max(viewModel.breakDuration, 1) : max(viewModel.workDuration, 1)
        let remaining = min(max(viewModel.remainingTime, 0), total)
        return (total - remaining) / total
    }
    
    private var formattedRemainingTime: String {
        let seconds = Int(max(viewModel.remainingTime, 0))
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private var leadingPaddingForSettings: CGFloat {
        let sidebarWidth: CGFloat = 190
        let offsetBetweenSidebars: CGFloat = 5
        return router.isSidebarVisible ? (sidebarWidth + offsetBetweenSidebars) : offsetBetweenSidebars
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskItem.self, PomodoroItem.self, configurations: config)
    
    PomodoroView(viewModel: PomodoroViewModelImpl(interactor: PomodoroInteractorImpl(), router: PomodoroRouterImpl(appRouter: AppRouter()), modelContext: container.mainContext))
}

