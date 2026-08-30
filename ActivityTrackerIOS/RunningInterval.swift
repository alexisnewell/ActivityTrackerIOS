struct RunningInterval: Identifiable, Codable {
    let id: UUID

    var repetitions: Int

    var distance: Double?
    var duration: TimeInterval?

    var pace: Double?
    var recovery: TimeInterval?
}