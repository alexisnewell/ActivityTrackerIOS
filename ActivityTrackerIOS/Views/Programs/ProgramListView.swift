//
//  ProgramListView.swift
//  ActivityTrackerIOS
//

import SwiftUI

struct ProgramListView: View {
    @Environment(\.dismiss) private var dismiss

    let onRunProgram: (Program) -> Void
    let onRecordRunningProgram: (RunningProgram) -> Void

    @State private var programs: [Program] = []
    @State private var programBeingEdited: Program?
    @State private var showNewProgramSheet = false
    @State private var programPendingDelete: Program?

    @State private var runningPrograms: [RunningProgram] = []
    @State private var runningProgramBeingEdited: RunningProgram?
    @State private var showNewRunningProgramSheet = false

    @State private var selectedProgramType: ProgramType = .strength

    var body: some View {
        VStack(spacing: 0) {

            Picker("Program Type", selection: $selectedProgramType) {
                Text("Strength")
                    .tag(ProgramType.strength)

                Text("Running")
                    .tag(ProgramType.running)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedProgramType == .strength {
                strengthProgramsView
            } else {
                runningProgramsView
            }
        }
        .navigationTitle("Programs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if selectedProgramType == .strength {
                        showNewProgramSheet = true
                    } else {
                        showNewRunningProgramSheet = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            loadPrograms()
            loadRunningPrograms()
        }
        .sheet(isPresented: $showNewProgramSheet) {
            ProgramEditorView { newProgram in
                programs.append(newProgram)
                ProgramStore.save(programs)
            }
        }
        .sheet(isPresented: $showNewRunningProgramSheet) {
            RunningProgramEditorView { newProgram in
                runningPrograms.append(newProgram)
                RunningProgramStore.save(runningPrograms)
            }
        }
        .sheet(item: $runningProgramBeingEdited) { program in
            RunningProgramEditorView(existingProgram: program) { updatedProgram in
                if let index = runningPrograms.firstIndex(where: { $0.id == updatedProgram.id }) {
                    runningPrograms[index] = updatedProgram
                    RunningProgramStore.save(runningPrograms)
                }
            }
        }
    }

    private func programRow(_ program: Program) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(program.name)
                .font(.headline)

            Text("\(program.exercises.count) exercises")
                .font(.caption)
                .foregroundColor(.secondary)

            if let date = program.scheduledDate {

                HStack(spacing: 5) {

                    Image(systemName: "calendar")

                    Text(
                        date.formatted(
                            .dateTime
                                .month(.abbreviated)
                                .day()
                                .year()
                        )
                    )
                }
                .font(.caption)
                .foregroundColor(Color(hex: "8c52ff"))
            }

            HStack {

                Button("Start") {

                    onRunProgram(program)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Edit") {

                    programBeingEdited = program
                }
                .buttonStyle(.bordered)

                Button("Delete") {

                    programPendingDelete = program
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private func runningProgramRow(_ program: RunningProgram) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(program.name)
                .font(.headline)

            Text(
                "\(program.workouts.count) workout\(program.workouts.count == 1 ? "" : "s")"
            )
            .font(.caption)
            .foregroundColor(.secondary)

            HStack {

                Button("Record") {

                    onRecordRunningProgram(program)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Edit") {

                    runningProgramBeingEdited = program
                }
                .buttonStyle(.bordered)

                Button("Delete") {

                    deleteRunningProgram(program)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private func loadPrograms() {
        programs = ProgramStore.load()
    }
    
    private func loadRunningPrograms() {
        runningPrograms = RunningProgramStore.load()
    }

    private func confirmDelete() {
        guard let target = programPendingDelete,
              let index = programs.firstIndex(where: { $0.id == target.id }) else {
            programPendingDelete = nil
            return
        }
        programs.remove(at: index)
        programPendingDelete = nil
        ProgramStore.save(programs)
    }

    private func deleteRunningProgram(_ program: RunningProgram) {
        runningPrograms.removeAll { $0.id == program.id }
        RunningProgramStore.save(runningPrograms)
    }
    
    private enum ProgramType {
        case strength
        case running
    }
    
    private var strengthProgramsView: some View {
        List {
            if programs.isEmpty {
                Text("No programs yet.\nTap + to create one.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            } else {
                ForEach(programs) { program in
                    programRow(program)
                }
            }
        }
    }
    
    private var runningProgramsView: some View {
        List {
            if runningPrograms.isEmpty {
                Text("No running programs yet.\nTap + to create one.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            } else {
                ForEach(runningPrograms) { program in
                    runningProgramRow(program)
                }
            }
        }
    }
}
