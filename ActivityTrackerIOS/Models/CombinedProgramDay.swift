//
//  CombinedProgramDay.swift
//  ActivityTrackerIOS
//

import Foundation

struct CombinedProgramDay: Identifiable, Codable {
    var id = UUID()
    var scheduledDate: Date? = nil
    var strengthProgram: Program? = nil
    var runningWorkout: RunningWorkout? = nil
    var notes: String = ""

    var isRestDay: Bool {
        strengthProgram == nil && runningWorkout == nil
    }
}
