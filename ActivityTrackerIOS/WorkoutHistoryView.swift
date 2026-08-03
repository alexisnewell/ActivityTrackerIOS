import SwiftUI

struct WorkoutHistoryView: View {
    let workouts: [Workout]

    private var groupedByDay: [(day: Date, workouts: [Workout])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workouts) { calendar.startOfDay(for: $0.date) }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (day: $0.key, workouts: $0.value.sorted { $0.date > $1.date }) }
    }

    var body: some View {
        Group {
            if workouts.isEmpty {
                Text("No workout history yet.")
                    .foregroundColor(.gray)
                    .padding(24)
            } else {
                List {
                    ForEach(groupedByDay, id: \.day) { section in
                        Section(section.day.formatted(date: .abbreviated, time: .omitted)) {
                            ForEach(section.workouts) { workout in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(workout.exerciseName).font(.headline)
                                        Text(workout.details)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(workout.date.formatted(date: .omitted, time: .shortened))
                                        .font(.caption2)
                                        .foregroundColor(.tertiary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("History")
    }
}