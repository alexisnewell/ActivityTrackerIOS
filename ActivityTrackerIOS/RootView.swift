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
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
                .tag(AppTab.home)

            StepsView()
                .tabItem {
                    Label("Steps", systemImage: "figure.walk")
                }
                .tag(AppTab.steps)

            WorkoutView()
                .tabItem {
                    Label("Weights", systemImage: "dumbbell.fill")
                }
                .tag(AppTab.workouts)
        }
        .preferredColorScheme(.dark)
    }

    /// Uses a custom asset from Assets.xcassets if one exists with this name,
    /// otherwise falls back to a built-in SF Symbol so the tab bar never
    /// shows a blank icon while you're still adding your own images.
    @ViewBuilder
    private func tabIcon(assetName: String, systemFallback: String, title: String) -> some View {
        if UIImage(named: assetName) != nil {
            Label {
                Text(title)
            } icon: {
                Image(assetName)
                    .renderingMode(.original) // forces iOS to keep the real color; tab bars ignore Contents.json otherwise
            }
        } else {
            Label(title, systemImage: systemFallback)
        }
    }
}

#Preview {
    RootView()
}
