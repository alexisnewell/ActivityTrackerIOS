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
        List {
            if programs.isEmpty {
                Text("No running programs yet.\nTap + to create one.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            } else {
                ForEach(programs) { program in
                    programRow(program)
                }
            }
        }
        .navigationTitle("Running Programs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewProgramSheet = true
                } label: {
                    Image(systemName: "plus")
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
        .padding(.vertical, 4)
    }

    private func loadPrograms() {
        programs = RunningProgramStore.load()
    }

    private func deleteProgram(_ program: RunningProgram) {
        programs.removeAll { $0.id == program.id }
        RunningProgramStore.save(programs)
    }
}
