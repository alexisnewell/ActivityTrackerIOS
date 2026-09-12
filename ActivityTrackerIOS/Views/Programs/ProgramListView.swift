import SwiftUI

struct ProgramListView: View {

    @Environment(\.dismiss) private var dismiss

    var showAddButton: Bool = true
    let onRunProgram: (Program) -> Void
    let onRecordRunningProgram: (RunningProgram) -> Void

    @State private var programs: [Program] = []
    @State private var programBeingEdited: Program?
    @State private var showNewProgramSheet = false
    @State private var programPendingDelete: Program?

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Header

            HStack {

                Text("Strength Programs")
                    .font(.headline)

                Spacer()

                if showAddButton {
                    Button {
                        showNewProgramSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            // MARK: - Rows

            if programs.isEmpty {

                Text("No programs yet.\nTap + to create one.")
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
        .onAppear {
            loadPrograms()
        }
        .sheet(isPresented: $showNewProgramSheet) {

            ProgramEditorView { newProgram in
                programs.append(newProgram)
                ProgramStore.save(programs)
            }
        }
        .sheet(item: $programBeingEdited) { program in

            ProgramEditorView(existingProgram: program) { updatedProgram in

                if let index = programs.firstIndex(
                    where: { $0.id == updatedProgram.id }
                ) {
                    programs[index] = updatedProgram
                    ProgramStore.save(programs)
                }
            }
        }
        .alert(
            "Delete Program?",
            isPresented: Binding(
                get: { programPendingDelete != nil },
                set: { if !$0 { programPendingDelete = nil } }
            )
        ) {

            Button("Delete", role: .destructive) {
                confirmDelete()
            }

            Button("Cancel", role: .cancel) {
                programPendingDelete = nil
            }

        } message: {

            Text("Are you sure you want to delete this program?")
        }
    }

    // MARK: - Program Row

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
        .padding(.vertical, 8)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Data

    private func loadPrograms() {
        programs = ProgramStore.load()
    }

    private func confirmDelete() {

        guard let target = programPendingDelete,
              let index = programs.firstIndex(
                where: { $0.id == target.id }
              )
        else {
            programPendingDelete = nil
            return
        }

        programs.remove(at: index)
        programPendingDelete = nil

        ProgramStore.save(programs)
    }
}
