import Foundation

struct ChatRequest: Codable {
    let message: String
    let user: UserContext?
}

struct UserContext: Codable {
    let workout_history: [WorkoutHistoryEntry]
}

struct WorkoutHistoryEntry: Codable {
    let exerciseName: String
    let sets: Int
    let reps: Int
    let weight: Double
    let date: Date
}

struct ChatResponse: Codable {
    let message: String
    let program: Program?
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
