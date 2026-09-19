import SwiftUI

struct ProgramsView: View {

    @Binding var selectedTab: AppTab

    @State private var showStrength = true
    @State private var showRunning = false
    @State private var showCombined = false

    @State private var recordingProgram: RunningProgram?
    @State private var isBuildingCombinedProgram = false
    @State private var combinedProgramBeingEdited: CombinedProgram?

    @State private var combinedPrograms: [CombinedProgram] = []
    @State private var strengthPrograms: [Program] = []
    @State private var runningPrograms: [RunningProgram] = []
    @EnvironmentObject private var programRunner: ProgramRunner

    private var availableRunningWorkouts: [RunningWorkout] {
        runningPrograms.flatMap { $0.workouts }
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 0) {

                    // MARK: - Program Type Filters

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Program Types")
                            .font(.headline)

                        CheckboxRow(
                            title: "Strength",
                            isChecked: $showStrength
                        )

                        CheckboxRow(
                            title: "Running",
                            isChecked: $showRunning
                        )

                        CheckboxRow(
                            title: "Combined",
                            isChecked: $showCombined
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))

                    Divider()

                    // MARK: - Selected Program Lists

                    if showStrength {
                        ProgramListView(
                            onRunProgram: { program in
                                programRunner.start(program)
                                selectedTab = .workouts
                            },
                            onRecordRunningProgram: { program in
                                recordingProgram = program
                            }
                        )
                    }

                    if showRunning {
                        RunningProgramListView { program in
                            recordingProgram = program
                        }
                    }

                    if showCombined {
                        CombinedProgramListView(
                            programs: combinedPrograms,
                            onCreateNew: {
                                isBuildingCombinedProgram = true
                            },
                            onEditProgram: { program in
                                combinedProgramBeingEdited = program
                            },
                            onStartItem: { item in

                                switch item {

                                case .strength(let program):
                                    programRunner.start(program)
                                    selectedTab = .workouts

                                case .running(let workout):
                                    recordingProgram = RunningProgram(
                                        id: UUID(),
                                        name: "Combined session",
                                        workouts: [workout]
                                    )
                                }
                            }
                        )
                    }

                    if !showStrength &&
                        !showRunning &&
                        !showCombined {

                        VStack(spacing: 8) {

                            Image(systemName: "checkmark.square")
                                .font(.system(size: 40))

                            Text("No program types selected")
                                .font(.headline)

                            Text("Select one or more types above.")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 40)
                    }
                }
            }
            .navigationTitle("Programs")
        }
        .onAppear {
            combinedPrograms = CombinedProgramStore.load()
            strengthPrograms = ProgramStore.load()
            runningPrograms = RunningProgramStore.load()
        }
        .sheet(isPresented: $isBuildingCombinedProgram) {
            CombinedProgramBuilderView(
                availableStrengthPrograms: strengthPrograms,
                availableRunningWorkouts: availableRunningWorkouts,
                onSave: { newProgram in
                    combinedPrograms.append(newProgram)
                    CombinedProgramStore.save(combinedPrograms)
                }
            )
        }
        .sheet(item: $combinedProgramBeingEdited) { program in
            CombinedProgramBuilderView(
                availableStrengthPrograms: strengthPrograms,
                availableRunningWorkouts: availableRunningWorkouts,
                existingProgram: program,
                onSave: { updatedProgram in
                    if let index = combinedPrograms.firstIndex(where: { $0.id == updatedProgram.id }) {
                        combinedPrograms[index] = updatedProgram
                        CombinedProgramStore.save(combinedPrograms)
                    }
                }
            )
        }
        .sheet(item: $recordingProgram) { program in
            RunningProgramRecorderView(program: program)
        }
    }
}


struct CheckboxRow: View {

    let title: String

    @Binding var isChecked: Bool

    var body: some View {

        Button {
            isChecked.toggle()
        } label: {

            HStack(spacing: 10) {

                Image(
                    systemName: isChecked
                        ? "checkmark.square.fill"
                        : "square"
                )
                .font(.system(size: 24))
                .foregroundStyle(
                    isChecked
                        ? Color(hex: "8c52ff")
                        : .secondary
                )

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
