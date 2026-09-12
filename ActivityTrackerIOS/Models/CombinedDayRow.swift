//
//  CombinedDayRow.swift
//  ActivityTrackerIOS
//

import SwiftUI

struct CombinedDayRow: View {
    let day: CombinedProgramDay

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Icons
            VStack(spacing: 6) {
                if day.isRestDay {
                    Image(systemName: "bed.double")
                } else {
                    if day.strengthProgram != nil {
                        Image(systemName: "dumbbell")
                    }
                    if day.runningWorkout != nil {
                        Image(systemName: "figure.run")
                    }
                }
            }
            .font(.title3)
            .frame(width: 32)

            // Content
            VStack(alignment: .leading, spacing: 4) {

                if day.isRestDay {

                    Text("Rest Day")
                        .font(.headline)

                    Text("Recovery")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                } else {

                    if let program = day.strengthProgram {
                        Text(program.name)
                            .font(.headline)

                        Text("Strength")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let workout = day.runningWorkout {
                        Text(workout.name)
                            .font(.headline)

                        Text("Running")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let date = day.scheduledDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
