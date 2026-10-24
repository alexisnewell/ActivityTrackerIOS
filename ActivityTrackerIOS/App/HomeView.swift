import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: AppTab

    @State private var workouts: [Workout] = []
    private let storageKey = "workout_list"
    @State private var programs: [Program] = []
    @Query(sort: \DailySteps.date, order: .reverse)
    private var stepHistory: [DailySteps]
    @State private var combinedPrograms: [CombinedProgram] = []
    @State private var showFullCalendar = false

    @Query(sort: \ActivityRecord.date, order: .reverse)
    private var activityRecords: [ActivityRecord]

    private let accent = Color(hex: "8c52ff")
    private let card = Color(hex: "17172b")
    private let muted = Color(hex: "a5a4c5")

    private var todaySteps: Int {
        stepHistory.first(where: { Calendar.current.isDateInToday($0.date) })?.steps ?? 0
    }

    private var stepProgress: Double {
        min(Double(todaySteps) / 10_000.0, 1.0)
    }

    private var workoutsThisWeek: Int {
        let calendar = Calendar.current
        return workouts.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.count
    }

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today) else {
            return [today]
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                stepsCard
                weeklyStats
                nextWorkoutCard
                quickActions
                weekCard
                exportSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "111123"), Color(hex: "080812")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showFullCalendar) {
            NavigationStack {
                ScrollView {
                    WorkoutCalendarView(workouts: workouts)
                        .padding()
                }
                .background(Color(hex: "080812").ignoresSafeArea())
                .navigationTitle("Workout Calendar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showFullCalendar = false
                        }
                        .foregroundStyle(accent)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear {
            loadWorkouts()
            loadPrograms()
            loadCombinedPrograms()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(Date.now.formatted(.dateTime.weekday(.wide)))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(muted)
                Text("Your activity")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("Small steps. Big progress.")
                    .font(.subheadline)
                    .foregroundStyle(muted)
            }
            Spacer()
            Image(systemName: "figure.run")
                .font(.title2.weight(.semibold))
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
                .accessibilityLabel("Activity Tracker")
        }
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Today's steps", systemImage: "figure.walk")
                    .font(.headline)
                    .foregroundStyle(muted)
                Spacer()
                Text("\(Int(stepProgress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(accent)
            }
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(todaySteps.formatted())
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                        Text("/ 10,000")
                            .font(.subheadline)
                            .foregroundStyle(muted)
                    }
                    ProgressView(value: stepProgress)
                        .tint(accent)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    Text(todaySteps >= 10_000 ? "Daily goal reached — great work!" : "\(max(10_000 - todaySteps, 0).formatted()) steps to your goal")
                        .font(.caption)
                        .foregroundStyle(muted)
                        .padding(.top, 4)
                }
                Spacer(minLength: 0)
                ZStack {
                    Circle().stroke(accent.opacity(0.2), lineWidth: 9)
                    Circle()
                        .trim(from: 0, to: stepProgress)
                        .stroke(accent, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "shoeprints.fill")
                        .font(.title2)
                        .foregroundStyle(accent)
                }
                .frame(width: 66, height: 66)
            }
        }
        .padding(18)
        .background(card, in: RoundedRectangle(cornerRadius: 22))
    }

    private var weeklyStats: some View {
        HStack(spacing: 10) {
            Button {
                selectedTab = .workouts
            } label: {
                statCard(title: "Workouts", value: "\(workoutsThisWeek)", detail: "this week", icon: "dumbbell.fill", tint: accent)
            }

            Button {
                selectedTab = .activityTracker
            } label: {
                statCard(title: "Activities", value: "\(activityRecords.count)", detail: "recorded", icon: "figure.run", tint: Color(hex: "36c98f"))
            }

            Button {
                selectedTab = .programs
            } label: {
                statCard(title: "Programs", value: "\(programs.count + combinedPrograms.count)", detail: "saved", icon: "calendar", tint: Color(hex: "62a0ff"))
            }
        }
        .buttonStyle(.plain)
    }

    private func statCard(title: String, value: String, detail: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 11))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(card, in: RoundedRectangle(cornerRadius: 18))
    }

    private var nextWorkoutCard: some View {
        Button {
            selectedTab = .workouts
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.16), in: RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 5) {
                    Text("Keep your momentum")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(muted)
                    Text("Ready for your next workout?")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Open workout history")
                        .font(.caption)
                        .foregroundStyle(muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(muted)
            }
            .padding(16)
            .background(
                LinearGradient(colors: [Color(hex: "272044"), card], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.title3.bold())
                .foregroundStyle(.white)
            HStack(spacing: 10) {
                actionButton("Log workout", icon: "dumbbell.fill", tint: accent, tab: .workouts)
                actionButton("Start run", icon: "figure.run", tint: Color(hex: "36c98f"), tab: .activityTracker)
                actionButton("Steps", icon: "shoeprints.fill", tint: Color(hex: "62a0ff"), tab: .steps)
                actionButton("Programs", icon: "sparkles", tint: Color(hex: "c084fc"), tab: .programs)
            }
        }
    }

    private func actionButton(_ title: String, icon: String, tint: Color, tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 84)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(tint.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("This week", systemImage: "calendar")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    showFullCalendar = true
                } label: {
                    HStack(spacing: 4) {
                        Text("View calendar")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    VStack(spacing: 7) {
                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption)
                            .foregroundStyle(muted)
                        Text(date.formatted(.dateTime.day()))
                            .font(.subheadline.bold())
                            .foregroundStyle(Calendar.current.isDateInToday(date) ? .white : muted)
                            .frame(width: 30, height: 30)
                            .background(Calendar.current.isDateInToday(date) ? accent : .clear, in: Circle())
                        Circle()
                            .fill(hasWorkout(on: date) ? Color(hex: "36c98f") : .clear)
                            .frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(card, in: RoundedRectangle(cornerRadius: 20))
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Take your data with you")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Export your activity history and programs.")
                .font(.caption)
                .foregroundStyle(muted)
            ExportButton(
                workouts: workouts,
                stepHistory: stepHistory,
                activityRecords: activityRecords,
                programs: programs,
                combinedPrograms: combinedPrograms
            )
            .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card, in: RoundedRectangle(cornerRadius: 20))
    }

    private func hasWorkout(on date: Date) -> Bool {
        Calendar.current.isDateInToday(date) && !workouts.isEmpty ||
        workouts.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private func loadWorkouts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Workout].self, from: data) else {
            workouts = []
            return
        }
        workouts = decoded
    }

    private func loadPrograms() {
        programs = ProgramStore.load()
    }

    private func loadCombinedPrograms() {
        combinedPrograms = CombinedProgramStore.load()
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
