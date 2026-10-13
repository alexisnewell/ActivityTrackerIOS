
import Foundation

struct Exercise: Codable, Identifiable {
    let name: String
    let primaryMuscle: String
    let secondaryMuscles: [String]
    let equipment: [String]
    let difficulty: Int
    let executionTips: [String]

    var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name
        case primaryMuscle = "primary_muscle"
        case secondaryMuscles = "secondary_muscles"
        case equipment
        case difficulty
        case executionTips = "execution_tips"
    }
}
