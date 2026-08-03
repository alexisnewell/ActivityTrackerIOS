import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: AppTab

    @State private var workouts: [Workout] = []
    private let storageKey = "workout_list"

    @Query(sort: \DailySteps.date, order: .reverse)
    private var stepHistory: [DailySteps]

    var body: some View {
        VStack(spacing: 24) {
            titleView
            subtitleView
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
            ExportButton(workouts: workouts, stepHistory: stepHistory)
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
        Text("What do you want to track?")
            .font(.subheadline)
            .foregroundColor(.gray)
    }

    private func homeCard(title: String, iconName: String, systemFallback: String, tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 8) {
                logoImage(named: iconName, systemFallback: systemFallback)
                    .frame(width: 40, height: 40)
                Text(title)
                    .font(.title3).bold()
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color(white: 0.12))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func logoImage(named assetName: String, systemFallback: String) -> some View {
        if UIImage(named: assetName) != nil {
            Image(assetName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: systemFallback)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
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

#Preview {
    HomeView(selectedTab: .constant(.home))
}
