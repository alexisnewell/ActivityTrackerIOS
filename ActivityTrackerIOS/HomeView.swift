import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: AppTab

    @State private var workouts: [Workout] = []
    private let storageKey = "workout_list"

    @Query(sort: \DailySteps.date, order: .reverse)
    private var stepHistory: [DailySteps]
    
    @Query(sort: \ActivityRecord.date, order: .reverse)
    private var activityRecords: [ActivityRecord]

    var body: some View {
        VStack(spacing: 24) {
            titleView
            subtitleView
            homeCard(title: "Start Activity",
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
            homeCard(title: "Programs",
                     iconName: "program_logo",
                     systemFallback:"list.bullet.rectangle",
                     tab: .programs
            )
            Spacer()
            ExportButton(workouts: workouts, stepHistory: stepHistory, activityRecords: activityRecords)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 64)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
        .onAppear(perform: loadWorkouts)
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

    private func homeCard(title: String, iconName: String, systemFallback: String, tab: AppTab, iconColor: Color? = nil) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 8) {
                logoImage(named: iconName, systemFallback: systemFallback, iconColor: iconColor ?? .white)
                    .frame(width: 40, height: 40)
                Text(title)
                    .font(.title3).bold()
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
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
