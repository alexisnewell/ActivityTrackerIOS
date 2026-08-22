//
//  RunningPRsView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-22.
//


import SwiftUI
import SwiftData

struct RunningPRsView: View {
    @Query(sort: \ActivityRecord.date, order: .reverse)
    private var records: [ActivityRecord]

    private var prs: [RunningPR] {
        RunningPRCalculator.calculate(from: records)
    }

    var body: some View {
        Group {
            if prs.isEmpty {
                Text("No running PRs yet.\nComplete a run of at least 1K to get started!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(24)
            } else {
                List {
                    ForEach(StandardDistances.all) { distance in
                        if let pr = prs.first(where: { $0.distance.name == distance.name }) {
                            prRow(pr)
                        } else {
                            lockedRow(distance)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Running PRs")
    }

    private func prRow(_ pr: RunningPR) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(pr.distance.name).font(.headline)
                Text(pr.paceFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(pr.timeFormatted)
                    .font(.title3).bold()
                Text(pr.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func lockedRow(_ distance: StandardDistance) -> some View {
        HStack {
            Text(distance.name).font(.headline)
            Spacer()
            Text("Not yet completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .opacity(0.5)
    }
}

#Preview {
    NavigationStack {
        RunningPRsView()
    }
}