import Foundation

enum CSVExporter {

    // MARK: - Unified workout export

    /// One CSV row, used to merge completed workouts, planned strength
    /// programs, and planned combined-program days into a single file.
    private struct WorkoutRow {
        let date: Date
        let status: String   // "Completed" or "Planned"
        let source: String   // e.g. "Workout", "Program: Push Day", "Combined: Push Speed"
        let name: String     // exercise or running-workout name
        let sets: String
        let reps: String
        let weight: String
        let detail: String   // free-form extra info, e.g. running interval summary
    }

    /// Builds a single CSV combining completed workouts, planned strength
    /// programs, and planned combined-program days, sorted by date. Any
    /// section can be passed empty (e.g. omit completed data if the export
    /// is "Planned only").
    static func generateWorkoutHistoryCSV(
        completedWorkouts: [Workout] = [],
        plannedPrograms: [Program] = [],
        plannedCombinedDays: [CombinedProgram.ScheduledDay] = []
    ) -> String {

        var rows: [WorkoutRow] = []

        // Completed workouts
        for workout in completedWorkouts {
            rows.append(
                WorkoutRow(
                    date: workout.date,
                    status: "Completed",
                    source: "Workout",
                    name: workout.exerciseName,
                    sets: "\(workout.sets)",
                    reps: "\(workout.reps)",
                    weight: "\(workout.weight)",
                    detail: ""
                )
            )
        }

        // Planned strength programs
        for program in plannedPrograms {
            guard let scheduledDate = program.scheduledDate else { continue }

            for exercise in program.exercises {
                rows.append(
                    WorkoutRow(
                        date: scheduledDate,
                        status: "Planned",
                        source: "Program: \(program.name)",
                        name: exercise.exerciseName,
                        sets: "\(exercise.sets)",
                        reps: "\(exercise.reps)",
                        weight: "\(exercise.weight)",
                        detail: ""
                    )
                )
            }
        }

        // Planned combined-program days (strength + running)
        for entry in plannedCombinedDays {
            let source = "Combined: \(entry.programName)"

            if let strengthProgram = entry.day.strengthProgram {
                for exercise in strengthProgram.exercises {
                    rows.append(
                        WorkoutRow(
                            date: entry.date,
                            status: "Planned",
                            source: source,
                            name: exercise.exerciseName,
                            sets: "\(exercise.sets)",
                            reps: "\(exercise.reps)",
                            weight: "\(exercise.weight)",
                            detail: ""
                        )
                    )
                }
            }

            if let runningWorkout = entry.day.runningWorkout {
                let intervalSummary = runningWorkout.intervals
                    .map(intervalSummaryText)
                    .joined(separator: "; ")

                rows.append(
                    WorkoutRow(
                        date: entry.date,
                        status: "Planned",
                        source: source,
                        name: runningWorkout.name,
                        sets: "",
                        reps: "",
                        weight: "",
                        detail: intervalSummary
                    )
                )
            }
        }

        // Sort everything chronologically
        rows.sort { $0.date < $1.date }

        // Build CSV text
        var csvText = "Date,Status,Source,Name,Sets,Reps,Weight (lbs),Detail\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for row in rows {
            let dateString = formatter.string(from: row.date)

            let source = row.source.replacingOccurrences(of: ",", with: " ")
            let name = row.name.replacingOccurrences(of: ",", with: " ")
            let detail = row.detail.replacingOccurrences(of: ",", with: " ")

            csvText.append(
                "\(dateString),\(row.status),\(source),\(name),\(row.sets),\(row.reps),\(row.weight),\(detail)\n"
            )
        }

        return csvText
    }

    private static func intervalSummaryText(_ interval: RunningInterval) -> String {
        if let distance = interval.distance {
            let distanceText = distance >= 1000
                ? String(format: "%.2fkm", distance / 1000)
                : String(format: "%.0fm", distance)
            return "\(interval.repetitions)x\(distanceText)"
        }

        if let duration = interval.duration {
            let totalSeconds = Int(duration)
            let durationText = String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
            return "\(interval.repetitions)x\(durationText)"
        }

        return "\(interval.repetitions)x?"
    }

    // MARK: - Other exports (unchanged)

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
    
    static func generateRunningPRsCSV(from records: [ActivityRecord]) -> String {
        var csvText = "Distance,Time,Pace,Date\n"
        let prs = RunningPRCalculator.calculate(from: records)

        for pr in prs {
            let dateString = pr.date.formatted(date: .abbreviated, time: .omitted)
            csvText.append("\(pr.distance.name),\(pr.timeFormatted),\(pr.paceFormatted),\(dateString)\n")
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
