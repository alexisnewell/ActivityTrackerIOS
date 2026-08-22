//
//  StandardDistance.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-22.
//


import Foundation

struct StandardDistance: Identifiable {
    var id: String { name }
    let name: String
    let miles: Double
}

enum StandardDistances {
    static let all: [StandardDistance] = [
        StandardDistance(name: "1K", miles: 0.621371),
        StandardDistance(name: "Mile", miles: 1.0),
        StandardDistance(name: "5K", miles: 3.10686),
        StandardDistance(name: "10K", miles: 6.21371),
        StandardDistance(name: "Half Marathon", miles: 13.1094),
        StandardDistance(name: "Marathon", miles: 26.2188)
    ]
}

struct RunningPR: Identifiable {
    var id: String { distance.name }
    let distance: StandardDistance
    let estimatedSeconds: Int
    let date: Date
    let sourceRunDistance: Double

    var timeFormatted: String {
        let hours = estimatedSeconds / 3600
        let minutes = (estimatedSeconds % 3600) / 60
        let seconds = estimatedSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var paceFormatted: String {
        let paceSeconds = Double(estimatedSeconds) / distance.miles
        let minutes = Int(paceSeconds) / 60
        let seconds = Int(paceSeconds) % 60
        return String(format: "%d:%02d /mi", minutes, seconds)
    }
}

enum RunningPRCalculator {
    /// Estimates a PR for each standard distance from completed runs.
    /// Since sessions store total distance/duration rather than exact splits,
    /// a run's average pace is used to estimate the time it would take to cover
    /// each standard distance — only runs that actually covered at least that
    /// distance are eligible, and the fastest (lowest) estimate wins.
    static func calculate(from records: [ActivityRecord]) -> [RunningPR] {
        let runs = records.filter { $0.type == ActivityType.run.rawValue && $0.distanceMiles > 0 }

        var results: [RunningPR] = []

        for distance in StandardDistances.all {
            let eligible = runs.filter { $0.distanceMiles >= distance.miles }
            guard !eligible.isEmpty else { continue }

            let best = eligible.min { lhs, rhs in
                let lhsPace = Double(lhs.durationSeconds) / lhs.distanceMiles
                let rhsPace = Double(rhs.durationSeconds) / rhs.distanceMiles
                return lhsPace < rhsPace
            }

            if let best {
                let pacePerMile = Double(best.durationSeconds) / best.distanceMiles
                let estimatedSeconds = Int(pacePerMile * distance.miles)
                results.append(RunningPR(
                    distance: distance,
                    estimatedSeconds: estimatedSeconds,
                    date: best.date,
                    sourceRunDistance: best.distanceMiles
                ))
            }
        }

        return results
    }
}