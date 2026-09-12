struct CombinedProgramBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var weeks = 4
    @State private var days: [CombinedProgramDay] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Details") {
                    TextField("Plan name", text: $name)
                    Stepper("Duration: \(weeks) weeks", value: $weeks, in: 1...52)
                }

                Section("Weekly Schedule") {
                    ForEach($days) { $day in
                        DayRow(day: $day)
                    }
                    Button("Add Day") {
                        days.append(CombinedProgramDay(dayOfWeek: days.count + 1, kind: .rest))
                    }
                }
            }
            .navigationTitle("New Combined Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // build CombinedProgram(name:, weeks:, days:) and persist
                        dismiss()
                    }
                    .disabled(name.isEmpty || days.isEmpty)
                }
            }
        }
    }
}

struct DayRow: View {
    @Binding var day: CombinedProgramDay

    var body: some View {
        Picker("Day \(day.dayOfWeek)", selection: Binding(
            get: { dayKindTag(day.kind) },
            set: { newTag in day.kind = defaultKind(for: newTag) }
        )) {
            Text("Rest").tag(0)
            Text("Strength").tag(1)
            Text("Running").tag(2)
        }
    }

    private func dayKindTag(_ kind: ProgramDayKind) -> Int {
        switch kind {
        case .rest: return 0
        case .strength: return 1
        case .running: return 2
        }
    }

    private func defaultKind(for tag: Int) -> ProgramDayKind {
        switch tag {
        case 1: return .strength(StrengthWorkout.placeholder)
        case 2: return .running(RunningWorkout.placeholder)
        default: return .rest
        }
    }
}