//
//  RunningProgramListView.swift
//

import SwiftUI

struct RunningProgramListView: View {

    let onRecordProgram: (RunningProgram) -> Void

    @State private var programs: [RunningProgram] = []
    @State private var programBeingEdited: RunningProgram?
    @State private var showNewProgramSheet = false

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header

            HStack {
                Text("Running Programs")
                    .font(.headline)

                Spacer()

                Button {
                    showNewProgramSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            // MARK: - Rows

            if programs.isEmpty {
                Text("No running programs yet.\nTap + to create one.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.top, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(programs) { program in
                        programRow(program)
                        Divider()
                    }
                }
            }
        }
        .onAppear(perform: loadPrograms)
        .sheet(isPresented: $showNewProgramSheet) {
            RunningProgramEditorView { newProgram in
                programs.append(newProgram)
                RunningProgramStore.save(programs)
            }
        }
        .sheet(item: $programBeingEdited) { program in
            RunningProgramEditorView(existingProgram: program) { updatedProgram in
                if let index = programs.firstIndex(where: { $0.id == updatedProgram.id }) {
                    programs[index] = updatedProgram
                    RunningProgramStore.save(programs)
                }
            }
        }
    }

    private func programRow(_ program: RunningProgram) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(program.name)
                .font(.headline)

            Text("\(program.workouts.count) workout\(program.workouts.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Button("Record") {
                    onRecordProgram(program)
                }
                .buttonStyle(.borderedProminent)

                Button("Edit") {
                    programBeingEdited = program
                }
                .buttonStyle(.bordered)

                Button("Delete") {
                    deleteProgram(program)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func loadPrograms() {
        programs = RunningProgramStore.load()
    }

    private func deleteProgram(_ program: RunningProgram) {
        programs.removeAll { $0.id == program.id }
        RunningProgramStore.save(programs)
    }
}
