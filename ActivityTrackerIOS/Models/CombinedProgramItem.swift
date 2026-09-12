//
//  CombinedProgramItem.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//


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