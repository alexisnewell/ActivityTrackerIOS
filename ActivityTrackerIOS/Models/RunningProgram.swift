//
//  RunningProgram.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-30.
//
import Foundation

struct RunningProgram: Identifiable, Codable {
    let id: UUID
    var name: String
    var workouts: [RunningWorkout]
}
