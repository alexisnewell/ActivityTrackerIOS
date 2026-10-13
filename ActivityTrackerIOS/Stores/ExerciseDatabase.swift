
import Foundation

final class ExerciseDatabase {
    static let shared = ExerciseDatabase()

    private(set) var exercises: [Exercise] = []

    private init() {
        guard let url = Bundle.main.url(
            forResource: "exercises",
            withExtension: "json"
        ) else {
            print("Exercise database file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            exercises = try JSONDecoder().decode(
                [Exercise].self,
                from: data
            )
            print("Loaded \(exercises.count) exercises")
        } catch {
            print("Could not decode exercise database: \(error)")
        }
    }

    func search(
        muscle: String,
        equipment: String?
    ) -> [Exercise] {
        return exercises.filter { exercise in
            let muscleText = (
                [exercise.primaryMuscle] + exercise.secondaryMuscles
            ).joined(separator: " ").lowercased()

            let matchesMuscle = muscleText.contains(muscle.lowercased())

            let matchesEquipment: Bool
            if let equipment = equipment {
                matchesEquipment = exercise.equipment.contains {
                    $0.localizedCaseInsensitiveContains(equipment)
                }
            } else {
                matchesEquipment = true
            }

            return matchesMuscle && matchesEquipment
        }
    }
}
