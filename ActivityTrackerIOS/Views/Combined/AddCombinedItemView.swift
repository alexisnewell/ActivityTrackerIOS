//
//  AddCombinedItemView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//


import SwiftUI

struct AddCombinedItemView: View {
    let strengthPrograms: [Program]
    let runningWorkouts: [RunningWorkout]
    let onAdd: (ProgramDayKind) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Strength Programs

                Section("Strength") {
                    if strengthPrograms.isEmpty {
                        Text("No strength programs available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(strengthPrograms) { program in
                            Button {
                                onAdd(.strength(program))
                            } label: {
                                HStack {
                                    Image(systemName: "dumbbell")

                                    Text(program.name)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }

                // MARK: - Running Workouts

                Section("Running") {
                    if runningWorkouts.isEmpty {
                        Text("No running workouts available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(runningWorkouts) { workout in
                            Button {
                                onAdd(.running(workout))
                            } label: {
                                HStack {
                                    Image(systemName: "figure.run")

                                    Text(workout.name)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }

                // MARK: - Rest

                Section {
                    Button {
                        onAdd(.rest)
                    } label: {
                        HStack {
                            Image(systemName: "bed.double")

                            Text("Rest Day")

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Add Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}