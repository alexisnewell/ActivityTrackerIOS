
import SwiftUI

struct ExerciseBrowserView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedMuscle = "All"
    @State private var selectedEquipment = "All"
    @State private var selectedExercises: Set<String> = []
    @State private var showFilters = false
    @State private var showSaveAlert = false
    @State private var workoutName = "My Workout"
    @State private var savedMessage = ""

    private let muscles = [
        "All", "Chest", "Back", "Arms",
        "Shoulders", "Legs", "Core"
    ]

    private var allExercises: [Exercise] {
        ExerciseDatabase.shared.exercises
    }

    private var equipmentOptions: [String] {
        let equipment = allExercises.flatMap { $0.equipment }
        let uniqueEquipment = Set(equipment.filter { !$0.isEmpty })
        return ["All"] + uniqueEquipment.sorted()
    }

    private var filteredExercises: [Exercise] {
        allExercises.filter { exercise in
            let query = searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            let matchesSearch = query.isEmpty
                || exercise.name.localizedCaseInsensitiveContains(query)
                || exercise.primaryMuscle.localizedCaseInsensitiveContains(query)
                || exercise.secondaryMuscles.contains {
                    $0.localizedCaseInsensitiveContains(query)
                }
                || exercise.equipment.contains {
                    $0.localizedCaseInsensitiveContains(query)
                }

            let muscleNames = (
                [exercise.primaryMuscle] + exercise.secondaryMuscles
            ).joined(separator: " ").lowercased()

            let matchesMuscle: Bool

            switch selectedMuscle {
            case "All":
                matchesMuscle = true
            case "Arms":
                matchesMuscle = [
                    "arm", "bicep", "tricep", "forearm"
                ].contains { muscleNames.contains($0) }
            case "Legs":
                matchesMuscle = [
                    "leg", "quad", "hamstring", "glute", "calf"
                ].contains { muscleNames.contains($0) }
            case "Core":
                matchesMuscle = [
                    "core", "abdominal", "abs", "oblique"
                ].contains { muscleNames.contains($0) }
            default:
                matchesMuscle = muscleNames.contains(
                    selectedMuscle.lowercased()
                )
            }

            let matchesEquipment = selectedEquipment == "All"
                || exercise.equipment.contains {
                    $0.localizedCaseInsensitiveCompare(
                        selectedEquipment
                    ) == .orderedSame
                }

            return matchesSearch && matchesMuscle && matchesEquipment
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            filterSection

            HStack {
                Text("\(filteredExercises.count) exercises")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                if !selectedExercises.isEmpty {
                    Text("\(selectedExercises.count) selected")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: "8c52ff"))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            if allExercises.isEmpty {
                ContentUnavailableView(
                    "No Exercises Loaded",
                    systemImage: "dumbbell",
                    description: Text(
                        "Check that exercises.json is included in your app bundle."
                    )
                )
            } else if filteredExercises.isEmpty {
                ContentUnavailableView.search(
                    text: searchText
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredExercises) { exercise in
                            exerciseCard(exercise)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }

            bottomBar
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) {
            filterSheet
                .presentationDetents([.medium, .large])
        }
        .alert("Save Workout", isPresented: $showSaveAlert) {
            TextField("Workout name", text: $workoutName)

            Button("Cancel", role: .cancel) {}

            Button("Save") {
                saveWorkout()
            }
        } message: {
            Text(
                "Save \(selectedExercises.count) selected exercises to your programs."
            )
        }
        .alert("Workout Saved", isPresented: Binding(
            get: { !savedMessage.isEmpty },
            set: { if !$0 { savedMessage = "" } }
        )) {
            Button("OK") {
                savedMessage = ""
            }
        } message: {
            Text(savedMessage)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search exercises...", text: $searchText)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    showFilters = true
                } label: {
                    Label("Filters", systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color(hex: "8c52ff"))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Spacer()

                if selectedMuscle != "All"
                    || selectedEquipment != "All" {
                    Button("Reset") {
                        selectedMuscle = "All"
                        selectedEquipment = "All"
                    }
                    .font(.subheadline)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(muscles, id: \.self) { muscle in
                        Button {
                            selectedMuscle = muscle
                        } label: {
                            Text(muscle)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedMuscle == muscle
                                    ? Color(hex: "8c52ff").opacity(0.15)
                                    : Color(.secondarySystemGroupedBackground)
                                )
                                .foregroundStyle(
                                    selectedMuscle == muscle
                                    ? Color(hex: "8c52ff")
                                    : Color.primary
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }

    private func exerciseCard(_ exercise: Exercise) -> some View {
        let isSelected = selectedExercises.contains(exercise.id)

        return HStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundStyle(Color(hex: "8c52ff"))
                .frame(width: 64, height: 70)
                .background(Color(hex: "8c52ff").opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(exercise.primaryMuscle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(exercise.equipment.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button {
                if isSelected {
                    selectedExercises.remove(exercise.id)
                } else {
                    selectedExercises.insert(exercise.id)
                }
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "8c52ff"))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                isSelected ? "Remove \(exercise.name)" : "Add \(exercise.name)"
            )
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            Button {
                workoutName = "My Workout"
                showSaveAlert = true
            } label: {
                Label(
                    "Build Workout (\(selectedExercises.count))",
                    systemImage: "plus"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    selectedExercises.isEmpty
                    ? Color.gray.opacity(0.35)
                    : Color(hex: "8c52ff")
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedExercises.isEmpty)
        }
        .padding()
        .background(.regularMaterial)
    }

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Muscle Group") {
                    Picker("Muscle", selection: $selectedMuscle) {
                        ForEach(muscles, id: \.self) { muscle in
                            Text(muscle).tag(muscle)
                        }
                    }
                }

                Section("Equipment") {
                    Picker("Equipment", selection: $selectedEquipment) {
                        ForEach(equipmentOptions, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                }

                Section {
                    Button("Reset All Filters") {
                        selectedMuscle = "All"
                        selectedEquipment = "All"
                        searchText = ""
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Filter Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showFilters = false
                    }
                }
            }
        }
    }

    private func saveWorkout() {
        let selected = filteredExercises.filter {
            selectedExercises.contains($0.id)
        }

        guard !selected.isEmpty else { return }

        let programExercises: [ProgramExercise] = selected.map {
            exercise in

            ProgramExercise(
                exerciseName: exercise.name,
                sets: 3,
                reps: 10,
                weight: 0
            )
        }

        let trimmedName = workoutName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let program = Program(
            name: trimmedName.isEmpty ? "My Workout" : trimmedName,
            exercises: programExercises
        )

        var programs = ProgramStore.load()
        programs.append(program)
        ProgramStore.save(programs)

        selectedExercises.removeAll()
        savedMessage = "Your workout was saved to Programs."
    }
}
