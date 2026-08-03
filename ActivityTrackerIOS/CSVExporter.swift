import Foundation

enum CSVExporter {

    static func generateWorkoutHistoryCSV(from workouts: [Workout]) -> String {
        var csvText = "Date,Exercise,Sets,Reps,Weight (lbs)\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let sorted = workouts.sorted { $0.date < $1.date }

        for workout in sorted {
            let dateString = formatter.string(from: workout.date)
            let name = workout.exerciseName.replacingOccurrences(of: ",", with: " ")
            csvText.append("\(dateString),\(name),\(workout.sets),\(workout.reps),\(workout.weight)\n")
        }

        return csvText
    }

    static func generateStepsHistoryCSV(from history: [DailySteps]) -> String {
        var csvText = "Date,Steps\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let sorted = history.sorted { $0.date < $1.date }

        for day in sorted {
            let dateString = formatter.string(from: day.date)
            csvText.append("\(dateString),\(day.steps)\n")
        }
        return csvText
    }

    static func writeCSVToTempFile(_ csvText: String, filename: String) -> URL? {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }
}
