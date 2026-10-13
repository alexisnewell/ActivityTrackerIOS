
import Foundation

final class ExerciseDatabase {
    static let shared = ExerciseDatabase()

    private(set) var exercises: [Exercise] = []

    private init() {
        guard let url = Bundle.main.url(
            forResource: "exercises",
            withExtension: "json"
        ) else {
            print("❌ Exercise database file not found in app bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)

            let response = try JSONDecoder().decode(
                ExerciseDatabaseResponse.self,
                from: data
            )

            exercises = response.exercises

            print("✅ Loaded \(exercises.count) exercises")
        } catch {
            print("❌ Could not decode exercise database: \(error)")
        }
    }

    func search(
        muscle: String,
        equipment: String?
    ) -> [Exercise] {
        return exercises.filter { exercise in
            let muscleText = (
                [exercise.primaryMuscle] + exercise.muscleGroups
            ).joined(separator: " ").lowercased()

            let matchesMuscle = muscleText.contains(
                muscle.lowercased()
            )

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
