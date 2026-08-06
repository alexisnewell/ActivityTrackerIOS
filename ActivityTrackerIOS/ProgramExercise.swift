//
//  Program.swift
//  ActivityTrackerIOS
//

import Foundation

/// A single planned exercise inside a Program (target, not a logged result).
struct ProgramExercise: Identifiable, Codable {
    var id = UUID()
    var exerciseName: String
    var sets: Int
    var reps: Int
    var weight: Double
}

/// A named, ordered list of exercises a user can "run" from WorkoutView.
struct Program: Identifiable, Codable {
    var id = UUID()
    var name: String
    var exercises: [ProgramExercise]
}

enum ProgramStore {
    private static let storageKey = "program_list"

    static func load() -> [Program] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Program].self, from: data) else {
            return []
        }
        return decoded
    }

    static func save(_ programs: [Program]) {
        if let data = try? JSONEncoder().encode(programs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}