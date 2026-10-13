
import Foundation

struct ExerciseDatabaseResponse: Codable {
    let exercises: [Exercise]
    let running_workouts: [RunningWorkoutData]?
}

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let primaryMuscle: String
    let equipment: [String]
    let difficulty: String
    let instructions: String
    let muscleGroups: [String]
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case primaryMuscle = "primary_muscle"
        case equipment
        case difficulty
        case instructions
        case muscleGroups = "muscle_groups"
        case tags
    }
}

struct RunningWorkoutData: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let workoutType: String
    let difficulty: String
    let instructions: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case workoutType = "workout_type"
        case difficulty
        case instructions
    }
}
