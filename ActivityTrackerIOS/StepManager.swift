//
//  StepManager.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-01.
//
import Foundation
import SwiftData

class StepManager {

    func saveDailySteps(
        steps: Int,
        context: ModelContext
    ) {

        let calendar = Calendar.current

        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        )!

        let descriptor = FetchDescriptor<DailySteps>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay &&
                entry.date < endOfDay
            }
        )

        do {
            let results = try context.fetch(descriptor)

            if let existing = results.first {
                existing.steps = steps

            } else {
                let newEntry = DailySteps(
                    date: startOfDay,
                    steps: steps
                )

                context.insert(newEntry)
            }

            try context.save()

        } catch {
            print("Error saving steps: \(error)")
        }
    }
}
