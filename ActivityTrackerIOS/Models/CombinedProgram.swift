//
//  CombinedProgram.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//
import Foundation

struct CombinedProgram: Identifiable, Codable {
    var id: UUID
    var name: String
    var days: [CombinedProgramDay]

    /// The Monday that this plan's 7 days apply to. Always normalized to
    /// midnight on that week's Monday — see `mondayStartOfWeek`.
    var weekStartDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        days: [CombinedProgramDay],
        weekStartDate: Date
    ) {
        self.id = id
        self.name = name
        self.days = days
        self.weekStartDate = CombinedProgram.mondayStartOfWeek(for: weekStartDate)
    }

    // MARK: - Backward-compatible decoding

    private enum CodingKeys: String, CodingKey {
        case id, name, days, weekStartDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        days = try container.decode([CombinedProgramDay].self, forKey: .days)

        // Programs saved before weekStartDate existed won't have this key.
        // Fall back to the current week so they don't disappear from the calendar.
        let decodedDate = try container.decodeIfPresent(Date.self, forKey: .weekStartDate)
        weekStartDate = CombinedProgram.mondayStartOfWeek(for: decodedDate ?? Date())
    }

    // MARK: - Week math

    /// Returns midnight on the Monday of the week containing `date`.
    static func mondayStartOfWeek(for date: Date, calendar: Calendar = .current) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay) // Sunday = 1 ... Saturday = 7
        let daysFromMonday = (weekday + 5) % 7 // Monday = 0 ... Sunday = 6
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: startOfDay) ?? startOfDay
    }

    /// The Sunday that ends this plan's week.
    var weekEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
    }
}
