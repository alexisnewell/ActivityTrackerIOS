struct RunningWorkout: Identifiable, Codable {
    let id: UUID
    var name: String
    var intervals: [RunningInterval]
}