//
//  CombinedProgramListView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//


struct CombinedProgramListView: View {
    var programs: [CombinedProgram]
    var onCreateNew: () -> Void
    var onStartItem: (CombinedProgramItem) -> Void

    var body: some View {
        List {
            ForEach(programs) { program in
                Section(program.name) {
                    ForEach(program.items) { item in
                        Button {
                            onStartItem(item)
                        } label: {
                            CombinedItemSummaryRow(item: item)
                        }
                    }
                }
            }

            if programs.isEmpty {
                ContentUnavailableView(
                    "No Combined Plans Yet",
                    systemImage: "figure.mixed.cardio",
                    description: Text("Create a plan that mixes running and strength sessions.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onCreateNew()
                } label: {
                    Label("New Plan", systemImage: "plus")
                }
            }
        }
    }
}

struct CombinedItemSummaryRow: View {
    var item: CombinedProgramItem

    var body: some View {
        HStack {
            switch item.kind {
            case .strength(let program):
                Label(program.name, systemImage: "dumbbell")
            case .running:
                Label("Run", systemImage: "figure.run") // swap in workout.name if available
            case .rest:
                Label("Rest", systemImage: "moon.zzz")
            }
            Spacer()
            if let date = item.scheduledDate {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}