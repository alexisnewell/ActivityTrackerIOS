import Foundation

@MainActor
final class ProgramRunner: ObservableObject {
    @Published var activeProgram: Program?
    @Published var activeExerciseIndex: Int = 0

    var currentExercise: ProgramExercise? {
        guard let program = activeProgram, activeExerciseIndex < program.exercises.count else {
            return nil
        }
        return program.exercises[activeExerciseIndex]
    }

    func start(_ program: Program) {
        guard !program.exercises.isEmpty else { return }
        activeProgram = program
        activeExerciseIndex = 0
    }

    func advance() {
        guard let program = activeProgram else { return }
        activeExerciseIndex += 1
        if activeExerciseIndex >= program.exercises.count {
            end()
        }
    }

    func end() {
        activeProgram = nil
        activeExerciseIndex = 0
    }
}