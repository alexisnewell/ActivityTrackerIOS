//
//  DailySteps.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-01.
//

import Foundation
import SwiftData

@Model
class DailySteps {
    var date: Date
    var steps: Int

    init(date: Date = Date(), steps: Int) {
        self.date = date
        self.steps = steps
    }
}
