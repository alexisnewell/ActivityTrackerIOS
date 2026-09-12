//
//  CombinedProgramDay.swift
//  ActivityTrackerIOS
//

import Foundation

struct CombinedProgramDay: Identifiable, Codable {
    var id = UUID()
    var scheduledDate: Date? = nil
    var kind: ProgramDayKind
    var notes: String = ""
}