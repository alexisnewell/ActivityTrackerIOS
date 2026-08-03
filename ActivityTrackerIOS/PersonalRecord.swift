//
//  PersonalRecord.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-03.
//


import Foundation

struct PersonalRecord: Identifiable {
    var id: String { exerciseName }
    let exerciseName: String
    let bestWeight: Double
    let bestWeightReps: Int
    let bestWeightDate: Date
}

enum PRCalculator {
    static func calculate(from workouts: [Workout]) -> [PersonalRecord] {
        var best: [String: Workout] = [:]

        for workout in workouts {
            if let current = best[workout.exerciseName] {
                if workout.weight > current.weight {
                    best[workout.exerciseName] = workout
                }
            } else {
                best[workout.exerciseName] = workout
            }
        }

        return best.values
            .map {
                PersonalRecord(
                    exerciseName: $0.exerciseName,
                    bestWeight: $0.weight,
                    bestWeightReps: $0.reps,
                    bestWeightDate: $0.date
                )
            }
            .sorted { $0.exerciseName.localizedCaseInsensitiveCompare($1.exerciseName) == .orderedAscending }
    }

    /// Call this before appending a new workout, to detect a PR at log time
    static func isPR(exerciseName: String, weight: Double, in workouts: [Workout]) -> Bool {
        let currentBest = workouts
            .filter { $0.exerciseName.caseInsensitiveCompare(exerciseName) == .orderedSame }
            .map { $0.weight }
            .max() ?? 0
        return weight > currentBest
    }
}