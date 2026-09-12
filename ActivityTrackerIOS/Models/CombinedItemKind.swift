//
//  CombinedItemKind.swift
//  ActivityTrackerIOS
//

import Foundation

enum CombinedItemKind: Codable {
    case strength(Program)
    case running(RunningWorkout)
    case rest
}