import SwiftUI

struct ManualAddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Workout) -> Void

    @State private var name = ""
    @State private var setsText = ""
    @State private var repsText = ""
    @State private var weightText = ""
    @State private var showInvalidAlert = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise Name", text: $name)
                TextField("Sets", text: $setsText)
                    .keyboardType(.numberPad)
                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)
                TextField("Weight (lbs)", text: $weightText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .alert("Please enter valid values.", isPresented: $showInvalidAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty,
              let sets = Int(setsText), sets > 0,
              let reps = Int(repsText), reps > 0,
              let weight = Double(weightText), weight >= 0 else {
            showInvalidAlert = true
            return
        }

        onSave(Workout(exerciseName: trimmedName, sets: sets, reps: reps, weight: weight))
        dismiss()
    }
}