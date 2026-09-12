import SwiftUI

enum AppTab: Hashable {
    case home, steps, workouts, programs, activityTracker
}

struct RootView: View {
    @State private var selectedTab: AppTab = .home
    @StateObject private var programRunner = ProgramRunner()
    @State private var recordingProgram: RunningProgram?

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            ActivityTrackerView()
                .tabItem {
                    Label("Start Activity", systemImage: "play.fill")
                }
                .tag(AppTab.activityTracker)

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

            NavigationStack {
                ProgramListView(
                    onRunProgram: { _ in
                        // Selecting a program from the tab bar just shows the list;
                        // running one switches to Workouts where the run flow lives.
                        selectedTab = .workouts
                    },
                    onRecordRunningProgram: { program in
                        recordingProgram = program
                    }
                )
            }
                .tabItem {
                    Label("Programs", systemImage: "list.bullet.rectangle")
                }
                .tag(AppTab.programs)
        }
        .environmentObject(programRunner)
        .preferredColorScheme(.dark)
        .sheet(item: $recordingProgram) { program in
            RunningProgramRecorderView(program: program)
        }
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
