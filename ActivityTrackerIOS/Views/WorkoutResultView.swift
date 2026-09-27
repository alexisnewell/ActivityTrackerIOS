struct WorkoutResultView: View {

    let program: Program

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text(program.name)
                .font(.title3)
                .fontWeight(.bold)

            ForEach(program.exercises) { exercise in

                VStack(alignment: .leading, spacing: 6) {

                    Text(exercise.exerciseName)
                        .font(.headline)

                    Text(
                        "\(exercise.sets) sets × \(exercise.reps) reps"
                    )
                    .font(.subheadline)

                    if exercise.weight > 0 {
                        Text(
                            "Recommended weight: \(formatWeight(exercise.weight)) kg"
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            Color(hex: "8c52ff")
                        )
                    } else {
                        Text("Bodyweight")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color.secondary.opacity(0.12)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
        }
        .padding()
        .background(
            Color.secondary.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }

    private func formatWeight(_ weight: Double) -> String {

        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(weight))
        }

        return String(format: "%.1f", weight)
    }
}