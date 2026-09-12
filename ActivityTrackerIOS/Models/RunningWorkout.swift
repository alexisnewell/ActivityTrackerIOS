//
//  RunningWorkout.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-30.
//
import Foundation

struct RunningWorkout: Identifiable, Codable {
    let id: UUID
    var name: String
    var intervals: [RunningInterval]
    var scheduledDate: Date?
}
