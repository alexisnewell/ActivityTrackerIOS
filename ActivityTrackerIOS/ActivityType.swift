import Foundation
import SwiftData

enum ActivityType: String, Codable, CaseIterable {
    case walk = "Walk"
    case run = "Run"
}

@Model
class ActivityRecord {
    var type: String
    var date: Date
    var steps: Int
    var distanceMiles: Double
    var durationSeconds: Int

    init(type: ActivityType, date: Date = Date(), steps: Int, distanceMiles: Double, durationSeconds: Int) {
        self.type = type.rawValue
        self.date = date
        self.steps = steps
        self.distanceMiles = distanceMiles
        self.durationSeconds = durationSeconds
    }

    var durationFormatted: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}