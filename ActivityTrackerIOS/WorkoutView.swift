import SwiftUI

struct WorkoutView: View {

    @State private var workouts: [Workout] = []

    // Add-form fields
    @State private var name = ""
    @State private var setsText = ""
    @State private var repsText = ""
    @State private var weightText = ""

    @State private var nameError: String?
    @State private var setsError: String?
    @State private var repsError: String?
    @State private var weightError: String?

    @State private var showInvalidNumberAlert = false

    // Delete confirmation state — replaces the AlertDialog in WorkoutAdapter's delete button
    @State private var workoutPendingDelete: Workout?

    // Edit sheet state — replaces the dialog_edit_workout AlertDialog
    @State private var workoutBeingEdited: Workout?

    private let storageKey = "workout_list"

    var body: some View {
        VStack(spacing: 12) {
            titleView
            formView
            addButton
            listOrEmptyState
            Spacer()
        }
        .padding()
        .onAppear(perform: loadWorkouts)
        .alert("Please enter valid numbers.", isPresented: $showInvalidNumberAlert) {
            Button("OK", role: .cancel) {}
        }
        // Delete confirmation — mirrors "Delete Workout / Are you sure?" AlertDialog
        .alert(
            "Delete Workout",
            isPresented: Binding(
                get: { workoutPendingDelete != nil },
                set: { if !$0 { workoutPendingDelete = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { workoutPendingDelete = nil }
            Button("Delete", role: .destructive) { confirmDelete() }
        } message: {
            Text("Are you sure you want to delete this workout?")
        }
        // Edit sheet — mirrors dialog_edit_workout
        .sheet(item: $workoutBeingEdited) { workout in
            EditWorkoutSheet(workout: workout) { updated in
                saveEdit(updated)
            }
        }
    }

    // MARK: - Subviews

    private var titleView: some View {
        Text("Workout Tracker")
            .font(.title2).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formView: some View {
        VStack(spacing: 8) {
            labeledField("Exercise Name", text: $name, error: nameError)
            labeledField("Sets", text: $setsText, error: setsError, keyboard: .numberPad)
            labeledField("Reps", text: $repsText, error: repsError, keyboard: .numberPad)
            labeledField("Weight (lbs)", text: $weightText, error: weightError, keyboard: .decimalPad)
        }
    }

    private func labeledField(
        _ placeholder: String,
        text: Binding<String>,
        error: String?,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(keyboard)
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var addButton: some View {
        Button("Add Workout") {
            addWorkout()
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
    }

    @ViewBuilder
    private var listOrEmptyState: some View {
        if workouts.isEmpty {
            Text("No workouts yet.\nTap Add Workout to get started!")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(24)
        } else {
            List {
                ForEach(workouts) { workout in
                    workoutRow(workout)
                }
            }
            .listStyle(.plain)
        }
    }

    /// Replaces WorkoutViewHolder's bound row + its Edit/Delete buttons.
    private func workoutRow(_ workout: Workout) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workout.exerciseName).font(.headline)
                Text(workout.details).font(.subheadline)
            }
            Spacer()
            Button("Edit") {
                workoutBeingEdited = workout
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(6)

            Button("Delete") {
                workoutPendingDelete = workout
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.15))
            .cornerRadius(6)
            .tint(.red)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    // MARK: - Add validation

    private func addWorkout() {
        nameError = nil; setsError = nil; repsError = nil; weightError = nil

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedSets = setsText.trimmingCharacters(in: .whitespaces)
        let trimmedReps = repsText.trimmingCharacters(in: .whitespaces)
        let trimmedWeight = weightText.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            nameError = "Exercise name is required"
            return
        }
        guard !trimmedSets.isEmpty else {
            setsError = "Enter number of sets"
            return
        }
        guard !trimmedReps.isEmpty else {
            repsError = "Enter number of reps"
            return
        }
        guard !trimmedWeight.isEmpty else {
            weightError = "Enter weight"
            return
        }

        guard let sets = Int(trimmedSets),
              let reps = Int(trimmedReps),
              let weight = Double(trimmedWeight) else {
            showInvalidNumberAlert = true
            return
        }

        guard sets > 0 else {
            setsError = "Sets must be greater than 0"
            return
        }
        guard reps > 0 else {
            repsError = "Reps must be greater than 0"
            return
        }
        guard weight >= 0 else {
            weightError = "Weight cannot be negative"
            return
        }

        workouts.append(Workout(exerciseName: trimmedName, sets: sets, reps: reps, weight: weight))
        saveWorkouts()

        name = ""; setsText = ""; repsText = ""; weightText = ""
    }

    // MARK: - Delete (replaces WorkoutAdapter's delete button + AlertDialog)

    private func confirmDelete() {
        guard let target = workoutPendingDelete,
              let index = workouts.firstIndex(where: { $0.id == target.id }) else {
            workoutPendingDelete = nil
            return
        }
        workouts.remove(at: index)
        workoutPendingDelete = nil
        saveWorkouts()
    }

    // MARK: - Edit (replaces WorkoutAdapter's edit button + dialog_edit_workout)

    private func saveEdit(_ updated: Workout) {
        guard let index = workouts.firstIndex(where: { $0.id == updated.id }) else { return }
        workouts[index] = updated
        saveWorkouts()
    }

    // MARK: - Persistence

    private func saveWorkouts() {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadWorkouts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Workout].self, from: data) else {
            return
        }
        workouts = decoded
    }
}

/// Replaces dialog_edit_workout.xml + the edit AlertDialog logic in WorkoutAdapter.
private struct EditWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss

    let workout: Workout
    let onSave: (Workout) -> Void

    @State private var name: String
    @State private var setsText: String
    @State private var repsText: String
    @State private var weightText: String
    @State private var showEmptyFieldsAlert = false

    init(workout: Workout, onSave: @escaping (Workout) -> Void) {
        self.workout = workout
        self.onSave = onSave
        _name = State(initialValue: workout.exerciseName)
        _setsText = State(initialValue: String(workout.sets))
        _repsText = State(initialValue: String(workout.reps))
        _weightText = State(initialValue: String(workout.weight))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise Name", text: $name)
                TextField("Sets", text: $setsText)
                    .keyboardType(.numberPad)
                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)
                TextField("Weight", text: $weightText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Edit Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .alert("Please fill in all fields", isPresented: $showEmptyFieldsAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func save() {
        if setsText.trimmingCharacters(in: .whitespaces).isEmpty
            || repsText.trimmingCharacters(in: .whitespaces).isEmpty
            || weightText.trimmingCharacters(in: .whitespaces).isEmpty {
            showEmptyFieldsAlert = true
            return
        }
        guard let sets = Int(setsText),
              let reps = Int(repsText),
              let weight = Double(weightText) else {
            showEmptyFieldsAlert = true
            return
        }

        var updated = workout
        updated.exerciseName = name
        updated.sets = sets
        updated.reps = reps
        updated.weight = weight
        onSave(updated)
        dismiss()
    }
}

#Preview {
    WorkoutView()
}
