//
//  ProgramDayKind.swift
//  ActivityTrackerIOS
//

import Foundation

enum ProgramDayKind: Codable {
    case strength(Program)
    case running(RunningWorkout)
    case rest
}
