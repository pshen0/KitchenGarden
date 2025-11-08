import SwiftUI
import SwiftData

struct HomeView<ViewModel: HomeViewModelImpl>: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        VStack {
                            Text("Kitchen Garden")
                                .bold()
                                .font(.system(size: 40))
                            Images.LocalImages.vegetables
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 4)
                        TasksCardView(viewModel: viewModel)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .flexibleLayout(for: geo.size.width)
                    
                    HStack(spacing: 10) {
                        PomodoroCardView(action: viewModel.routeToPomodoro)
                            .frame(maxWidth: .infinity)
                        StatsCardView(viewModel: viewModel)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .flexibleLayout(for: geo.size.width)
                }
                .padding(10)
            }
            .background(Colors.neutralBackground.ignoresSafeArea())
        }
        .onAppear {
            viewModel.loadTasks()
        }
    }

    
    struct TasksCardView: View {
        @ObservedObject var viewModel: HomeViewModelImpl
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("Tasks")
                        .foregroundStyle(.yellowAccent)
                        .font(.system(size: 30))
                        .bold()
                        .padding(.top)
                    Spacer()
                    Menu {
                        Button("Today") { viewModel.selectTaskPeriod(.today) }
                        Button("Week") { viewModel.selectTaskPeriod(.week) }
                        Button("Month") { viewModel.selectTaskPeriod(.month) }
                    } label: {
                        HStack {
                            Text(viewModel.tasksPeriod.rawValue)
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                            Images.SystemImages.chevronDown
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Colors.yellowAccent, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.incompleteTasks) { task in
                        HStack {
                            Button(action: {
                                viewModel.toggleTaskCompletion(task)
                            }) {
                                Images.SystemImages.checkmark
                                    .foregroundColor(Colors.yellowAccent)
                            }
                            .buttonStyle(.plain)
                            
                            Text(task.title)
                                .lineLimit(1)
                                .font(.system(size: 20))
                            
                            Spacer()
                            
                            Images.SystemImages.flag
                                .foregroundColor(viewModel.flagColor(for: task.priority))
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .frame(width: 800, height: 350)
            .background(Colors.systemSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 4)
        }
    }
    
    struct PomodoroCardView: View {
        var action: () -> Void
        
        var body: some View {
            VStack {
                Spacer()
                Text("Let's focus!")
                    .bold()
                    .foregroundStyle(Colors.redText)
                    .font(.system(size: 30))
                
                ZStack {
                    Circle()
                        .stroke(Colors.redSecondary, lineWidth: 15)
                    Images.LocalImages.tomatoTimer
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130)
                    Text("25:00")
                        .bold()
                        .font(.system(size: 30))
                        .foregroundStyle(Colors.pinkAccent)
                        .padding(.top, 25)
                }
                .frame(width: 200, height: 200)
                Spacer()
                Button(action:  {
                    action()
                }) {
                    Text("START!")
                        .bold()
                        .font(.system(size: 15))
                        .foregroundColor(Colors.redText)
                        .frame(width: 30 * 3, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .fill(Colors.redSecondary)
                        )
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .frame(width: 400, height: 350)
            .background(Colors.systemSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 4)
        }
    }
    
    struct StatsCardView: View {
        @ObservedObject var viewModel: HomeViewModelImpl

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Statistics")
                        .bold()
                        .foregroundStyle(Colors.greenAccent)
                        .font(.system(size: 30))
                    Spacer()

                    Menu {
                        Button("Today") { viewModel.selectStatsPeriod(.today) }
                        Button("Week") { viewModel.selectStatsPeriod(.week) }
                        Button("Month") { viewModel.selectStatsPeriod(.month) }
                    } label: {
                        HStack {
                            Text(viewModel.statsPeriod.rawValue)
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                            Images.SystemImages.chevronDown
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Colors.greenAccent, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)

                Spacer()

                HStack(alignment: .bottom, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total focus: \(viewModel.stats.totalTimeString)")
                            .font(.system(size: 20))
                        Text("Avg focus: \(viewModel.stats.avgTimeString)")
                            .font(.system(size: 20))
                        Text("Tasks done: \(viewModel.stats.totalTasks)")
                            .font(.system(size: 20))
                    }

                    Spacer()

                    let chartWidth: CGFloat = 500
                    let chartHeight: CGFloat = 120
                    let spacing: CGFloat = 4
                    let numberOfBars = CGFloat(viewModel.stats.chartData.count)
                    let barWidth = (chartWidth - (numberOfBars - 1) * spacing) / numberOfBars

                    let maxValue = max(viewModel.stats.chartData.map { $0.value }.max() ?? 1, 1) // ← Защита от 0
                    
                    let timeMarkers = [0, maxValue/2, maxValue].map { Int($0) }
                    
                    VStack(spacing: 8) {
                        // График
                        HStack(alignment: .bottom, spacing: spacing) {
                            ForEach(viewModel.stats.chartData, id: \.period) { bar in
                                @State var isHovered = false
                                
                                VStack {
                                    Rectangle()
                                        .fill(Colors.greenAccent)
                                        .frame(
                                            width: barWidth,
                                            height: max(8, CGFloat(bar.value) / CGFloat(maxValue) * chartHeight) // ← Минимальная высота 8
                                        )
                                        .cornerRadius(2) // ← Закругленные углы
                                        .onHover { hovering in
                                            isHovered = hovering
                                        }
                                    
                                    if isHovered {
                                        Text("\(bar.valueString)m") // ← Показываем минуты
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                            .padding(4)
                                            .background(Color.secondary.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                .animation(.easeInOut(duration: 0.15), value: isHovered)
                            }
                        }
                        .frame(width: chartWidth, height: chartHeight)
                        
                        // Подписи периодов
                        HStack(alignment: .top, spacing: spacing) {
                            ForEach(viewModel.stats.chartData, id: \.period) { bar in
                                Text(bar.period)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: barWidth)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .frame(width: chartWidth)
                    }
                }
                .padding(.top, 12)
            }
            .padding()
            .frame(width: 800, height: 350)
            .background(Colors.systemSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 4)
        }
    }
}

extension View {
    func flexibleLayout(for width: CGFloat, breakpoint: CGFloat = 900) -> some View {
        Group {
            if width > breakpoint {
                self
            } else {
                VStack(spacing: 20) {
                    self
                }
            }
        }
    }
}
