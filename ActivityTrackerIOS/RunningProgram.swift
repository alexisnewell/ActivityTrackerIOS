struct RunningProgram: Identifiable, Codable {
    let id: UUID
    var name: String
    var workouts: [RunningWorkout]
}