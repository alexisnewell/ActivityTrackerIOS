import SwiftUI

struct CombinedDayRow: View {
    let day: CombinedProgramDay

    var body: some View {
        HStack(spacing: 12) {

            // Icon
            Image(systemName: iconName)
                .font(.title3)
                .frame(width: 32)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let date = day.scheduledDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch day.kind {
        case .strength:
            return "dumbbell"

        case .running:
            return "figure.run"

        case .rest:
            return "bed.double"
        }
    }

    private var title: String {
        switch day.kind {
        case .strength(let program):
            return program.name

        case .running(let workout):
            return workout.name

        case .rest:
            return "Rest Day"
        }
    }

    private var subtitle: String {
        switch day.kind {
        case .strength:
            return "Strength"

        case .running:
            return "Running"

        case .rest:
            return "Recovery"
        }
    }
}