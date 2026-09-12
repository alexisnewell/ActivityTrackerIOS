import SwiftUI

struct CombinedProgramListView: View {
    var programs: [CombinedProgram]
    var onCreateNew: () -> Void
    var onEditProgram: (CombinedProgram) -> Void
    var onStartItem: (CombinedProgramDayItem) -> Void

    private static let weekdayNames = [
        "Monday", "Tuesday", "Wednesday", "Thursday",
        "Friday", "Saturday", "Sunday"
    ]

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header

            HStack {
                Text("Combined Programs")
                    .font(.headline)

                Spacer()

                Button {
                    onCreateNew()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            // MARK: - Rows

            if programs.isEmpty {
                ContentUnavailableView(
                    "No Combined Plans Yet",
                    systemImage: "figure.mixed.cardio",
                    description: Text(
                        "Create a plan that mixes running and strength sessions."
                    )
                )
                .padding(.top, 24)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(programs) { program in

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(program.name)
                                    .font(.headline)

                                Spacer()

                                Button("Edit") {
                                    onEditProgram(program)
                                }
                                .font(.caption)
                            }

                            Text(weekRangeLabel(for: program))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 6)

                        ForEach(Array(program.days.enumerated()), id: \.element.id) { index, day in
                            dayRow(index: index, day: day)
                            Divider()
                                .padding(.leading)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Week label

    private func weekRangeLabel(for program: CombinedProgram) -> String {
        let format = Date.FormatStyle.dateTime.month(.abbreviated).day()
        return "\(program.weekStartDate.formatted(format)) – \(program.weekEndDate.formatted(format))"
    }

    // MARK: - Day Row

    private func dayRow(index: Int, day: CombinedProgramDay) -> some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(Self.weekdayNames[index])
                .font(.caption)
                .foregroundStyle(.secondary)

            if day.isRestDay {

                Text("Rest")
                    .foregroundStyle(.secondary)

            } else {

                VStack(alignment: .leading, spacing: 4) {

                    if let program = day.strengthProgram {
                        Button {
                            onStartItem(.strength(program))
                        } label: {
                            Label(program.name, systemImage: "dumbbell.fill")
                        }
                    }

                    if let workout = day.runningWorkout {
                        Button {
                            onStartItem(.running(workout))
                        } label: {
                            Label(workout.name, systemImage: "figure.run")
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
