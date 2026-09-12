import SwiftUI

struct CombinedProgramBuilderView: View {
    @Environment(\.dismiss) private var dismiss

    let availableStrengthPrograms: [Program]
    let availableRunningWorkouts: [RunningWorkout]
    let existingProgram: CombinedProgram?
    let onSave: (CombinedProgram) -> Void

    @State private var name: String
    @State private var days: [CombinedProgramDay]
    @State private var weekStartDate: Date

    private static let weekdayNames = [
        "Monday", "Tuesday", "Wednesday", "Thursday",
        "Friday", "Saturday", "Sunday"
    ]

    init(
        availableStrengthPrograms: [Program],
        availableRunningWorkouts: [RunningWorkout],
        existingProgram: CombinedProgram? = nil,
        onSave: @escaping (CombinedProgram) -> Void
    ) {
        self.availableStrengthPrograms = availableStrengthPrograms
        self.availableRunningWorkouts = availableRunningWorkouts
        self.existingProgram = existingProgram
        self.onSave = onSave

        _name = State(initialValue: existingProgram?.name ?? "")

        // Always work with exactly 7 slots, Monday through Sunday.
        if let existingDays = existingProgram?.days, existingDays.count == 7 {
            _days = State(initialValue: existingDays)
        } else {
            _days = State(
                initialValue: (0..<7).map { _ in CombinedProgramDay() }
            )
        }

        _weekStartDate = State(
            initialValue: CombinedProgram.mondayStartOfWeek(
                for: existingProgram?.weekStartDate ?? Date()
            )
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Name") {
                    TextField("Plan name", text: $name)
                }

                Section("Week") {
                    DatePicker(
                        "Week Starting",
                        selection: $weekStartDate,
                        displayedComponents: .date
                    )
                    .onChange(of: weekStartDate) { newValue in
                        // Always snap back to that week's Monday, no matter what
                        // day the user tapped in the picker.
                        let monday = CombinedProgram.mondayStartOfWeek(for: newValue)
                        if !Calendar.current.isDate(monday, inSameDayAs: weekStartDate) {
                            weekStartDate = monday
                        }
                    }

                    Text(weekRangeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Days") {
                    ForEach(Array(days.indices), id: \.self) { index in
                        dayRow(index: index)
                    }
                }
            }
            .navigationTitle(existingProgram == nil ? "New Combined Program" : "Edit Combined Program")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let program = CombinedProgram(
                            id: existingProgram?.id ?? UUID(),
                            name: name,
                            days: days,
                            weekStartDate: weekStartDate
                        )

                        onSave(program)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    // MARK: - Week label

    private var weekRangeLabel: String {
        let monday = weekStartDate
        let sunday = Calendar.current.date(byAdding: .day, value: 6, to: monday) ?? monday

        let format = Date.FormatStyle.dateTime.month(.abbreviated).day()
        return "\(monday.formatted(format)) – \(sunday.formatted(format))"
    }

    // MARK: - Day Row

    private func dayRow(index: Int) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(Self.weekdayNames[index])
                .font(.subheadline.weight(.semibold))

            HStack {
                strengthMenu(index: index)
                runningMenu(index: index)
            }
        }
        .padding(.vertical, 4)
    }

    private func strengthMenu(index: Int) -> some View {
        Menu {
            Button("None") {
                days[index].strengthProgram = nil
            }

            ForEach(availableStrengthPrograms) { program in
                Button(program.name) {
                    days[index].strengthProgram = program
                }
            }
        } label: {
            pillLabel(
                icon: "dumbbell.fill",
                text: days[index].strengthProgram?.name ?? "Strength: None"
            )
        }
    }

    private func runningMenu(index: Int) -> some View {
        Menu {
            Button("None") {
                days[index].runningWorkout = nil
            }

            ForEach(availableRunningWorkouts) { workout in
                Button(workout.name) {
                    days[index].runningWorkout = workout
                }
            }
        } label: {
            pillLabel(
                icon: "figure.run",
                text: days[index].runningWorkout?.name ?? "Running: None"
            )
        }
    }

    private func pillLabel(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.15))
        .clipShape(Capsule())
    }
}
