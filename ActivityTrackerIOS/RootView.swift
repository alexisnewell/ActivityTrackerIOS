import SwiftUI

enum AppTab: Hashable {
    case home, steps, workouts
}

struct RootView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            StepsView()
                .tabItem {
                    Label("Steps", systemImage: "figure.walk")
                }
                .tag(AppTab.steps)

            WorkoutView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
                .tag(AppTab.workouts)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func tabIcon(assetName: String, systemFallback: String, title: String) -> some View {
        if UIImage(named: assetName) != nil {
            Label {
                Text(title)
            } icon: {
                Image(assetName)
                    .renderingMode(.original) 
            }
        } else {
            Label(title, systemImage: systemFallback)
        }
    }
}

#Preview {
    RootView()
}
