//
//  RunningProgramEditorView.swift
//  ActivityTrackerIOS
//

import SwiftUI

struct RunningProgramEditorView: View {

    @Environment(\.dismiss) private var dismiss

    let existingProgram: RunningProgram?
    let onSave: (RunningProgram) -> Void

    @State private var name: String
    @State private var workouts: [RunningWorkout]

    @State private var workoutBeingEdited: RunningWorkout?
    @State private var showNewWorkoutSheet = false

    init(
        existingProgram: RunningProgram? = nil,
        onSave: @escaping (RunningProgram) -> Void
    ) {
        self.existingProgram = existingProgram
        self.onSave = onSave

        _name = State(
            initialValue: existingProgram?.name ?? ""
        )

        _workouts = State(
            initialValue: existingProgram?.workouts ?? []
        )
    }

    var body: some View {

        NavigationStack {

            Form {

                // MARK: - Program Name

                Section("Program Name") {

                    TextField(
                        "e.g. 8-Week 5K Plan",
                        text: $name
                    )
                }

                // MARK: - Workouts

                Section("Workouts") {

                    if workouts.isEmpty {

                        Text("No workouts added yet.")
                            .foregroundColor(.secondary)

                    } else {

                        ForEach(workouts) { workout in

                            Button {
                                workoutBeingEdited = workout
                            } label: {
                                workoutRow(workout)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteWorkout)
                    }

                    Button("Add Workout") {
                        showNewWorkoutSheet = true
                    }
                }
            }

            .navigationTitle(
                existingProgram == nil
                    ? "New Running Program"
                    : "Edit Running Program"
            )

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button("Save") {
                        saveProgram()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespaces
                        ).isEmpty ||
                        workouts.isEmpty
                    )
                }
            }

            .sheet(isPresented: $showNewWorkoutSheet) {

                RunningWorkoutEditorView { newWorkout in
                    workouts.append(newWorkout)
                }
            }

            .sheet(item: $workoutBeingEdited) { workout in

                RunningWorkoutEditorView(
                    existingWorkout: workout
                ) { updatedWorkout in

                    if let index = workouts.firstIndex(
                        where: { $0.id == updatedWorkout.id }
                    ) {
                        workouts[index] = updatedWorkout
                    }
                }
            }
        }
    }

    // MARK: - Workout Row

    private func workoutRow(
        _ workout: RunningWorkout
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Text(workout.name)
                .font(.headline)
                .foregroundColor(.primary)

            Text(
                "\(workout.intervals.count) interval\(workout.intervals.count == 1 ? "" : "s")"
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Delete

    private func deleteWorkout(
        at offsets: IndexSet
    ) {
        workouts.remove(
            atOffsets: offsets
        )
    }

    // MARK: - Save

    private func saveProgram() {

        let program = RunningProgram(
            id: existingProgram?.id ?? UUID(),
            name: name.trimmingCharacters(
                in: .whitespaces
            ),
            workouts: workouts
        )

        onSave(program)
        dismiss()
    }
}
