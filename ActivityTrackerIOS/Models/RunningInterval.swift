//
//  RunningInterval.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-30.
//


import Foundation

struct RunningInterval: Identifiable, Codable {
    var id: UUID = UUID()
    var repetitions: Int
    var distance: Double?
    var duration: TimeInterval?
    var pace: Double?
    var recovery: TimeInterval?
}
