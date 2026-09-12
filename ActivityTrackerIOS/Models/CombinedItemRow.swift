//
//  CombinedItemRow.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//


//
//  CombinedItemRow.swift
//  ActivityTrackerIOS
//

import SwiftUI

struct CombinedItemRow: View {
    @Binding var item: CombinedProgramItem

    var body: some View {
        HStack {
            switch item.kind {
            case .strength(let program):
                Label(program.name, systemImage: "dumbbell")
            case .running:
                Label("Run", systemImage: "figure.run") // swap in workout.name if RunningWorkout has one
            case .rest:
                Label("Rest", systemImage: "moon.zzz")
            }

            Spacer()

            DatePicker(
                "",
                selection: Binding(
                    get: { item.scheduledDate ?? Date() },
                    set: { item.scheduledDate = $0 }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
        }
    }
}
