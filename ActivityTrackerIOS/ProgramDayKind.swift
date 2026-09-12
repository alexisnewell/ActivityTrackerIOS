enum ProgramDayKind {
    case strength(StrengthWorkout)
    case running(RunningWorkout)
    case rest
}

struct CombinedProgramDay: Identifiable {
    let id = UUID()
    var dayOfWeek: Int          // 1 = Monday ... 7 = Sunday, or just sequence index
    var kind: ProgramDayKind
    var notes: String = ""
}

struct CombinedProgram: Identifiable {
    let id = UUID()
    var name: String
    var weeks: Int
    var days: [CombinedProgramDay]   // repeats each week, or expand per-week if progressive
}