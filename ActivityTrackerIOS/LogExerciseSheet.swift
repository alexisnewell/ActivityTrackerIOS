import SwiftUI

struct LogExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    let exercise: ProgramExercise
    let onSave: (Workout) -> Void

    @State private var setsText: String
    @State private var repsText: String
    @State private var weightText: String
    @State private var showInvalidAlert = false

    init(exercise: ProgramExercise, onSave: @escaping (Workout) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        _setsText = State(initialValue: String(exercise.sets))
        _repsText = State(initialValue: String(exercise.reps))
        _weightText = State(initialValue: String(format: "%.1f", exercise.weight))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(exercise.exerciseName) {
                    TextField("Sets", text: $setsText)
                        .keyboardType(.numberPad)
                    TextField("Reps", text: $repsText)
                        .keyboardType(.numberPad)
                    TextField("Weight (lbs)", text: $weightText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Log Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") { save() }
                }
            }
            .alert("Please enter valid numbers.", isPresented: $showInvalidAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func save() {
        guard let sets = Int(setsText), sets > 0,
              let reps = Int(repsText), reps > 0,
              let weight = Double(weightText), weight >= 0 else {
            showInvalidAlert = true
            return
        }

        let workout = Workout(exerciseName: exercise.exerciseName, sets: sets, reps: reps, weight: weight)
        onSave(workout)
        dismiss()
    }
}