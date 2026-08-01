//
//  StepHistoryView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-01.
//

import SwiftUI
import SwiftData


struct StepHistoryView: View {

    @Environment(\.modelContext)
    private var context

    @Query(
        sort: \DailySteps.date,
        order: .reverse
    )
    private var history: [DailySteps]


    var body: some View {

        NavigationStack {

            List(history) { day in

                HStack {

                    VStack(alignment: .leading) {

                        Text(
                            day.date.formatted(
                                date: .abbreviated,
                                time: .omitted
                            )
                        )
                        .font(.headline)


                        Text(
                            "\(day.steps) steps"
                        )
                        .foregroundStyle(.secondary)

                    }


                    Spacer()

                }
            }

            .navigationTitle("Step History")
        }
    }
}
