//
//  ProgramDayKind.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//
import Foundation

enum CombinedItemKind: Codable {
    case strength(Program)
    case running(RunningWorkout)
    case rest
}

struct CombinedProgramItem: Identifiable, Codable {
    var id = UUID()
    var scheduledDate: Date? = nil   // mirrors Program.scheduledDate
    var kind: CombinedItemKind
}

struct CombinedProgram: Identifiable, Codable {
    var id = UUID()
    var name: String
    var items: [CombinedProgramItem]
}
