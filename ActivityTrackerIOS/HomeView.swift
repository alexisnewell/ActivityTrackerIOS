import SwiftUI

/// SwiftUI equivalent of HomeActivity.java + activity_home.xml.
///
/// Card taps switch tabs instead of firing an Intent — that's handled via
/// the `selectedTab` binding passed down from RootView, since SwiftUI's
/// TabView owns navigation centrally rather than each screen managing its own.
struct HomeView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        VStack(spacing: 24) {
            titleView
            subtitleView
            homeCard(
                title: "Steps",
                iconName: "step_logo",          // swap to your own asset name
                systemFallback: "figure.walk", // used only if the custom asset isn't found
                tab: .steps
            )
            homeCard(
                title: "Workouts",
                iconName: "weights_logo",
                systemFallback: "dumbbell",
                tab: .workouts
            )
            Spacer()
        }
        .padding(.top, 64)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
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

    /// One reusable card, matching cardSteps / cardWorkouts from activity_home.xml.
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

    /// Looks for a custom image in Assets.xcassets first; falls back to an
    /// SF Symbol if you haven't added that asset yet, so the app never
    /// shows a blank/missing icon while you're still adding your own logos.
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
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
