//
//  CombinedProgramItem.swift
//  ActivityTrackerIOS
//

import Foundation

struct CombinedProgramItem: Identifiable, Codable {
    var id = UUID()
    var scheduledDate: Date? = nil
    var kind: CombinedItemKind
}