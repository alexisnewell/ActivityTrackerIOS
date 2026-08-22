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
    // Must stay sorted ascending — ActivityTracker.checkSplits() depends on this order.
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
    let seconds: Int
    let date: Date

    var timeFormatted: String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    var paceFormatted: String {
        let paceSeconds = Double(seconds) / distance.miles
        let minutes = Int(paceSeconds) / 60
        let secs = Int(paceSeconds) % 60
        return String(format: "%d:%02d /mi", minutes, secs)
    }
}

enum RunningPRCalculator {
    /// Uses the actual GPS-measured split time recorded at the moment each
    /// standard distance was crossed during a run — real elapsed time, not an estimate.
    static func calculate(from records: [ActivityRecord]) -> [RunningPR] {
        let runs = records.filter { $0.type == ActivityType.run.rawValue }

        var best: [String: RunningPR] = [:]

        for run in runs {
            for distance in StandardDistances.all {
                guard let splitSeconds = run.splitSecondsByDistance[distance.name] else { continue }

                if let existing = best[distance.name] {
                    if splitSeconds < existing.seconds {
                        best[distance.name] = RunningPR(distance: distance, seconds: splitSeconds, date: run.date)
                    }
                } else {
                    best[distance.name] = RunningPR(distance: distance, seconds: splitSeconds, date: run.date)
                }
            }
        }

        return StandardDistances.all.compactMap { best[$0.name] }
    }
}
