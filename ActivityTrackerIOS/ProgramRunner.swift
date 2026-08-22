import Foundation

@MainActor
final class ProgramRunner: ObservableObject {
    @Published var activeProgram: Program?
    @Published var loggedIndices: Set<Int> = []

    var isComplete: Bool {
        guard let program = activeProgram else { return false }
        return !program.exercises.isEmpty && loggedIndices.count >= program.exercises.count
    }

    func start(_ program: Program) {
        guard !program.exercises.isEmpty else { return }
        activeProgram = program
        loggedIndices = []
    }

    func markLogged(index: Int) {
        loggedIndices.insert(index)
    }

    func end() {
        activeProgram = nil
        loggedIndices = []
    }
}
