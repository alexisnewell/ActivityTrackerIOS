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
    
    @Query(sort: \ActivityRecord.date, order: .reverse)
    private var activityRecords: [ActivityRecord]

    var body: some View {
        VStack(spacing: 24) {
            titleView
            subtitleView
            HStack(spacing: 10) {
                homeCard(
                    title: "Start Activity",
                    iconName: "",
                    systemFallback: "play.fill",
                    tab: .activityTracker,
                    iconColor: Color(hex: "8c52ff")
                )
                homeCard(
                    title: "Steps",
                    iconName: "step_logo",
                    systemFallback: "figure.walk",
                    tab: .steps
                )
                homeCard(
                    title: "Workouts",
                    iconName: "weights_logo",
                    systemFallback: "dumbbell",
                    tab: .workouts
                )
                homeCard(
                    title: "Programs",
                    iconName: "program_logo",
                    systemFallback: "list.bullet.rectangle",
                    tab: .programs
                )
            }
            Spacer()
            ScrollView(.vertical, showsIndicators: true) {
                WorkoutCalendarView(
                    workouts: workouts
                )
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: 400)
            HStack(spacing: 5) {
                  Image(systemName: "arrow.up.and.down")
                  Text("Scroll to view workout details")
              }
              .font(.caption)
              .foregroundColor(.gray)
            ExportButton(
                workouts: workouts,
                stepHistory: stepHistory,
                activityRecords: activityRecords,
                programs: programs,
                combinedPrograms: combinedPrograms
            )
            .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 64)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
        .onAppear {
            loadWorkouts()
            loadPrograms()
            loadCombinedPrograms()
        }
    }
    
    private var titleView: some View {
        Text("Activity Tracker")
            .font(.title).bold()
            .foregroundColor(.white)
    }

    private var subtitleView: some View {
        Text("Track all your runs and workouts.")
            .font(.subheadline)
            .foregroundColor(.gray)
    }

    private func homeCard(
        title: String,
        iconName: String,
        systemFallback: String,
        tab: AppTab,
        iconColor: Color? = nil
    ) -> some View {

        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {

                logoImage(
                    named: iconName,
                    systemFallback: systemFallback,
                    iconColor: iconColor ?? .white
                )
                .frame(width: 32, height: 32)

                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(width: 90, height: 90)
            .background(Color(white: 0.12))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
    @ViewBuilder
    private func logoImage(named assetName: String, systemFallback: String, iconColor: Color) -> some View {
        if UIImage(named: assetName) != nil {
            Image(assetName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: systemFallback)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(iconColor)
        }
    }

    private func loadWorkouts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Workout].self, from: data) else {
            return
        }
        workouts = decoded
    }
    private func loadPrograms() {
        programs = ProgramStore.load()

        print("Loaded programs: \(programs.count)")

        for program in programs {
            print("Program: \(program.name)")
            print("Scheduled: \(String(describing: program.scheduledDate))")
            print("Exercises: \(program.exercises.count)")
            
        }
    }
    private func loadCombinedPrograms() {
        combinedPrograms = CombinedProgramStore.load()

        print("Loaded combined programs: \(combinedPrograms.count)")

        for program in combinedPrograms {
            print("Combined program: \(program.name)")
            print("Week start: \(program.weekStartDate)")
            print("Scheduled days: \(program.scheduledDays.count)")
        }
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
