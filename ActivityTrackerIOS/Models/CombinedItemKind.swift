//
//  CombinedItemKind.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//


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