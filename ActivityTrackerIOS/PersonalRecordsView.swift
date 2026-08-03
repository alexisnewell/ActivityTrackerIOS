//
//  PersonalRecordsView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-03.
//


import SwiftUI

struct PersonalRecordsView: View {
    let workouts: [Workout]

    private var records: [PersonalRecord] {
        PRCalculator.calculate(from: workouts)
    }

    var body: some View {
        Group {
            if records.isEmpty {
                Text("No personal records yet.\nLog a workout to get started!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(24)
            } else {
                List(records) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.exerciseName).font(.headline)
                        HStack {
                            Text("\(record.bestWeight, specifier: "%.1f") lbs × \(record.bestWeightReps) reps")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(record.bestWeightDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Personal Records")
    }
}