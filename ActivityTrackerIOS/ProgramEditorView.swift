//
//  ProgramEditorView.swift
//  ActivityTrackerIOS
//

import SwiftUI

struct ProgramEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let existingProgram: Program?
    let onSave: (Program) -> Void

    @State private var name: String
    @State private var exercises: [ProgramExercise]

    @State private var exerciseName = ""
    @State private var setsText = ""
    @State private var repsText = ""
    @State private var weightText = ""
    @State private var showInvalidAlert = false

    init(existingProgram: Program? = nil, onSave: @escaping (Program) -> Void) {
        self.existingProgram = existingProgram
        self.onSave = onSave
        _name = State(initialValue: existingProgram?.name ?? "")
        _exercises = State(initialValue: existingProgram?.exercises ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Program Name") {
                    TextField("e.g. Push Day", text: $name)
                }

                Section("Exercises") {
                    if exercises.isEmpty {
                        Text("No exercises added yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(exercises) { exercise in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.exerciseName).font(.headline)
                                Text("Sets: \(exercise.sets) | Reps: \(exercise.reps) | Weight: \(String(format: "%.1f", exercise.weight)) lbs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteExercise)
                    }
                }

                Section("Add Exercise") {
                    TextField("Exercise Name", text: $exerciseName)
                    TextField("Sets", text: $setsText)
                        .keyboardType(.numberPad)
                    TextField("Reps", text: $repsText)
                        .keyboardType(.numberPad)
                    TextField("Weight (lbs)", text: $weightText)
                        .keyboardType(.decimalPad)
                    Button("Add Exercise") {
                        addExercise()
                    }
                }
            }
            .navigationTitle(existingProgram == nil ? "New Program" : "Edit Program")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveProgram() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || exercises.isEmpty)
                }
            }
            .alert("Please enter valid numbers.", isPresented: $showInvalidAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func addExercise() {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty,
              let sets = Int(setsText), sets > 0,
              let reps = Int(repsText), reps > 0,
              let weight = Double(weightText), weight >= 0 else {
            showInvalidAlert = true
            return
        }

        exercises.append(ProgramExercise(exerciseName: trimmedName, sets: sets, reps: reps, weight: weight))
        exerciseName = ""; setsText = ""; repsText = ""; weightText = ""
    }

    private func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }

    private func saveProgram() {
        let id = existingProgram?.id ?? UUID()
        let program = Program(id: id, name: name.trimmingCharacters(in: .whitespaces), exercises: exercises)
        onSave(program)
        dismiss()
    }
}