//
//  ProgramListView.swift
//  ActivityTrackerIOS
//

import SwiftUI

struct ProgramListView: View {
    @Environment(\.dismiss) private var dismiss

    let onRunProgram: (Program) -> Void

    @State private var programs: [Program] = []
    @State private var programBeingEdited: Program?
    @State private var showNewProgramSheet = false
    @State private var programPendingDelete: Program?

    var body: some View {
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
        .navigationTitle("Programs")
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
            ProgramEditorView { newProgram in
                programs.append(newProgram)
                ProgramStore.save(programs)
            }
        }
        .sheet(item: $programBeingEdited) { program in
            ProgramEditorView(existingProgram: program) { updated in
                if let index = programs.firstIndex(where: { $0.id == updated.id }) {
                    programs[index] = updated
                    ProgramStore.save(programs)
                }
            }
        }
        .alert(
            "Delete Program",
            isPresented: Binding(
                get: { programPendingDelete != nil },
                set: { if !$0 { programPendingDelete = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { programPendingDelete = nil }
            Button("Delete", role: .destructive) { confirmDelete() }
        } message: {
            Text("Are you sure you want to delete this program?")
        }
    }

    private func programRow(_ program: Program) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(program.name).font(.headline)
            Text("\(program.exercises.count) exercises")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                Button("Run") {
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

    private func loadPrograms() {
        programs = ProgramStore.load()
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
}