//
//  Workout.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-01.
//

import Foundation

/// Swift equivalent of Workout.java
struct Workout: Identifiable, Codable {
    var id = UUID()
    var exerciseName: String
    var sets: Int
    var reps: Int
    var weight: Double
    var date: Date = Date()

    var details: String {
        "Sets: \(sets) | Reps: \(reps) | Weight: \(String(format: "%.1f", weight)) lbs"
    }
}
