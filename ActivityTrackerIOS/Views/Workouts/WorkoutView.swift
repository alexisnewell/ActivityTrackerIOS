import SwiftUI

struct WorkoutView: View {

    @EnvironmentObject private var programRunner: ProgramRunner

    @State private var workouts: [Workout] = []
    @State private var workoutPendingDelete: Workout?
    @State private var workoutBeingEdited: Workout?
    @State private var showPRBanner = false
    @State private var prBannerMessage = ""

    @State private var showProgramPicker = false
    @State private var showManualAdd = false
    @State private var exerciseBeingLogged: ProgramExerciseLogTarget?
    @State private var recordingProgram: RunningProgram?

    private let storageKey = "workout_list"

    var body: some View {
        NavigationStack {
            mainContent
                .padding()
                .onAppear(perform: loadWorkouts)
                .alert("New Personal Record! 🎉", isPresented: $showPRBanner) {
                    Button("Nice!", role: .cancel) {}
                } message: {
                    Text(prBannerMessage)
                }
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
                .sheet(item: $exerciseBeingLogged) { target in
                    LogExerciseSheet(exercise: target.exercise) { workout in

                        var completedWorkout = workout

                        if let program = programRunner.activeProgram {
                            completedWorkout.programID = program.id
                        }

                        logWorkout(completedWorkout)

                        programRunner.markLogged(index: target.index)
                    }
                }
                .sheet(isPresented: $showProgramPicker) {
                    NavigationStack {
                        ProgramListView(showAddButton: false) { program in
                            programRunner.start(program)
                            showProgramPicker = false
                        } onRecordRunningProgram: { program in
                            recordingProgram = program
                        }
                    }
                }
                .sheet(isPresented: $showManualAdd) {
                    ManualAddWorkoutSheet { workout in
                        logWorkout(workout)
                    }
                }
                .sheet(item: $recordingProgram) { program in
                    RunningProgramRecorderView(program: program)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        navMenu
                    }
                }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 12) {
            titleView

            if let program = programRunner.activeProgram {
                activeProgramSection(program)
            } else {
                noActiveProgramCard
            }

            Divider()

            HStack {
                Text("All Workouts").font(.headline)
                Spacer()
                Button {
                    showManualAdd = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }

            listOrEmptyState
            Spacer()
        }
    }

    private var navMenu: some View {
        Menu {
            NavigationLink("History") {
                WorkoutHistoryView(workouts: workouts)
            }
            NavigationLink("Personal Records") {
                PersonalRecordsView(workouts: workouts)
            }
        } label: {
            Image(systemName: "chart.bar")
        }
    }

    private var titleView: some View {
        Text("Workout Tracker")
            .font(.title2).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var noActiveProgramCard: some View {
        VStack(spacing: 8) {
            Text("No program running")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Button("Select a Program") {
                showProgramPicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(12)
    }

    private func activeProgramSection(_ program: Program) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(program.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(programRunner.loggedIndices.count) of \(program.exercises.count) logged")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Button("End", role: .destructive) {
                    programRunner.end()
                }
                .buttonStyle(.bordered)
            }

            if programRunner.isComplete {
                Text("Program complete! 🎉")
                    .font(.subheadline).bold()
                    .foregroundColor(.green)
            }

            VStack(spacing: 6) {
                ForEach(Array(program.exercises.enumerated()), id: \.element.id) { index, exercise in
                    programExerciseRow(index: index, exercise: exercise)
                }
            }
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(12)
    }
    
    private func programExerciseRow(index: Int, exercise: ProgramExercise) -> some View {
        let isLogged = programRunner.loggedIndices.contains(index)

        return Button {
            if !isLogged {
                exerciseBeingLogged = ProgramExerciseLogTarget(index: index, exercise: exercise)
            }
        } label: {
            HStack {
                Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isLogged ? .green : .white.opacity(0.6))
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.exerciseName)
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                    Text("Sets: \(exercise.sets) | Reps: \(exercise.reps) | Weight: \(String(format: "%.1f", exercise.weight)) lbs")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(8)
            .background(Color(white: 0.22))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(isLogged)
    }
    // MARK: - All Workouts list

    @ViewBuilder
    private var listOrEmptyState: some View {
        if workouts.isEmpty {
            Text("No workouts yet.")
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

    // MARK: - Logging

    private func logWorkout(_ workout: Workout) {
        let hitPR = PRCalculator.isPR(exerciseName: workout.exerciseName, weight: workout.weight, in: workouts)

        workouts.append(workout)
        saveWorkouts()

        if hitPR {
            prBannerMessage = "\(workout.exerciseName): \(String(format: "%.1f", workout.weight)) lbs"
            showPRBanner = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

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

    private func saveEdit(_ updated: Workout) {
        guard let index = workouts.firstIndex(where: { $0.id == updated.id }) else { return }
        workouts[index] = updated
        saveWorkouts()
    }

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

private struct ProgramExerciseLogTarget: Identifiable {
    let index: Int
    let exercise: ProgramExercise
    var id: UUID { exercise.id }
}

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
        .environmentObject(ProgramRunner())
}
