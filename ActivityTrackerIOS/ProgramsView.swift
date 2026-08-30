```swift
import SwiftUI

struct ProgramsView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Program type tabs
                Picker("Program Type", selection: $selectedTab) {
                    Text("Strength")
                        .tag(0)

                    Text("Running")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Selected tab
                if selectedTab == 0 {
                    ProgramListView { program in
                        // Start strength program
                    }
                } else {
                    RunningProgramListView()
                }

                Spacer()
            }
            .navigationTitle("Programs")
        }
    }
}
```
