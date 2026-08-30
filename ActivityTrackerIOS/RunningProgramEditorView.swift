```swift
//
//  RunningProgramEditorView.swift
//  ActivityTrackerIOS
//

import SwiftUI

struct RunningProgramEditorView: View {

    @Environment(\.dismiss) private var dismiss

    let existingProgram: RunningProgram?
    let onSave: (RunningProgram) -> Void

    @State private var name: String
    @State private var intervals: [RunningInterval]

    @State private var repetitionsText = ""
    @State private var distanceText = ""
    @State private var durationMinutesText = ""
    @State private var durationSecondsText = ""
    @State private var paceMinutesText = ""
    @State private var paceSecondsText = ""
    @State private var recoveryMinutesText = ""
    @State private var recoverySecondsText = ""

    @State private var showInvalidAlert = false

    init(
        existingProgram: RunningProgram? = nil,
        onSave: @escaping (RunningProgram) -> Void
    ) {
        self.existingProgram = existingProgram
        self.onSave = onSave

        _name = State(
            initialValue: existingProgram?.name ?? ""
        )

        _intervals = State(
            initialValue: existingProgram?.intervals ?? []
        )
    }

    var body: some View {

        NavigationStack {

            Form {

                // MARK: - Program Name

                Section("Program Name") {

                    TextField(
                        "e.g. Speed Workout",
                        text: $name
                    )
                }

                // MARK: - Intervals

                Section("Intervals") {

                    if intervals.isEmpty {

                        Text("No intervals added yet.")
                            .foregroundColor(.secondary)

                    } else {

                        ForEach(
                            Array(intervals.enumerated()),
                            id: \.element.id
                        ) { index, interval in

                            intervalRow(
                                interval,
                                index: index
                            )
                        }
                        .onDelete(perform: deleteInterval)
                    }
                }

                // MARK: - Add Interval

                Section("Add Interval") {

                    TextField(
                        "Repetitions",
                        text: $repetitionsText
                    )
                    .keyboardType(.numberPad)

                    TextField(
                        "Distance (m)",
                        text: $distanceText
                    )
                    .keyboardType(.decimalPad)

                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    HStack {

                        TextField(
                            "Minutes",
                            text: $durationMinutesText
                        )
                        .keyboardType(.numberPad)

                        Text(":")
                            .foregroundColor(.secondary)

                        TextField(
                            "Seconds",
                            text: $durationSecondsText
                        )
                        .keyboardType(.numberPad)
                    }

                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {

                        TextField(
                            "Pace min",
                            text: $paceMinutesText
                        )
                        .keyboardType(.numberPad)

                        Text(":")

                        TextField(
                            "sec",
                            text: $paceSecondsText
                        )
                        .keyboardType(.numberPad)

                        Text("/km")
                            .foregroundColor(.secondary)
                    }

                    Text("Pace")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {

                        TextField(
                            "Recovery min",
                            text: $recoveryMinutesText
                        )
                        .keyboardType(.numberPad)

                        Text(":")

                        TextField(
                            "sec",
                            text: $recoverySecondsText
                        )
                        .keyboardType(.numberPad)
                    }

                    Text("Recovery")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Add Interval") {
                        addInterval()
                    }
                }
            }

            .navigationTitle(
                existingProgram == nil
                    ? "New Running Program"
                    : "Edit Running Program"
            )

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button("Save") {
                        saveProgram()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespaces
                        ).isEmpty ||
                        intervals.isEmpty
                    )
                }
            }

            .alert(
                "Invalid Interval",
                isPresented: $showInvalidAlert
            ) {

                Button("OK", role: .cancel) {}
            } message: {

                Text(
                    "Enter a valid number of repetitions and either a distance or duration."
                )
            }
        }
    }

    // MARK: - Interval Row

    private func intervalRow(
        _ interval: RunningInterval,
        index: Int
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Text(
                "\(interval.repetitions) × \(intervalDescription(interval))"
            )
            .font(.headline)

            if let pace = interval.pace {

                Text(
                    "Pace: \(formatPace(pace))/km"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }

            if let recovery = interval.recovery {

                Text(
                    "Recovery: \(formatTime(recovery))"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Interval Description

    private func intervalDescription(
        _ interval: RunningInterval
    ) -> String {

        if let distance = interval.distance {

            if distance >= 1000 {
                return "\(distance / 1000, specifier: "%.2f") km"
            } else {
                return "\(distance, specifier: "%.0f") m"
            }
        }

        if let duration = interval.duration {

            return formatTime(duration)
        }

        return "Unknown"
    }

    // MARK: - Add Interval

    private func addInterval() {

        guard
            let repetitions = Int(repetitionsText),
            repetitions > 0
        else {
            showInvalidAlert = true
            return
        }

        let distance = Double(distanceText)

        let durationMinutes = Int(
            durationMinutesText
        ) ?? 0

        let durationSeconds = Int(
            durationSecondsText
        ) ?? 0

        let duration: TimeInterval?

        if durationMinutes > 0 || durationSeconds > 0 {

            guard durationSeconds < 60 else {
                showInvalidAlert = true
                return
            }

            duration = TimeInterval(
                durationMinutes * 60 +
                durationSeconds
            )

        } else {

            duration = nil
        }

        let paceMinutes = Int(
            paceMinutesText
        ) ?? 0

        let paceSeconds = Int(
            paceSecondsText
        ) ?? 0

        let pace: Double?

        if paceMinutes > 0 || paceSeconds > 0 {

            guard paceSeconds < 60 else {
                showInvalidAlert = true
                return
            }

            pace = Double(
                paceMinutes * 60 +
                paceSeconds
            ) / 60.0

        } else {

            pace = nil
        }

        let recoveryMinutes = Int(
            recoveryMinutesText
        ) ?? 0

        let recoverySeconds = Int(
            recoverySecondsText
        ) ?? 0

        let recovery: TimeInterval?

        if recoveryMinutes > 0 || recoverySeconds > 0 {

            guard recoverySeconds < 60 else {
                showInvalidAlert = true
                return
            }

            recovery = TimeInterval(
                recoveryMinutes * 60 +
                recoverySeconds
            )

        } else {

            recovery = nil
        }

        guard distance != nil || duration != nil else {
            showInvalidAlert = true
            return
        }

        intervals.append(
            RunningInterval(
                repetitions: repetitions,
                distance: distance,
                duration: duration,
                pace: pace,
                recovery: recovery
            )
        )

        clearFields()
    }

    // MARK: - Clear Fields

    private func clearFields() {

        repetitionsText = ""
        distanceText = ""
        durationMinutesText = ""
        durationSecondsText = ""
        paceMinutesText = ""
        paceSecondsText = ""
        recoveryMinutesText = ""
        recoverySecondsText = ""
    }

    // MARK: - Delete

    private func deleteInterval(
        at offsets: IndexSet
    ) {
        intervals.remove(
            atOffsets: offsets
        )
    }

    // MARK: - Save

    private func saveProgram() {

        let program = RunningProgram(
            id: existingProgram?.id ?? UUID(),
            name: name.trimmingCharacters(
                in: .whitespaces
            ),
            intervals: intervals
        )

        onSave(program)
        dismiss()
    }

    // MARK: - Formatting

    private func formatTime(
        _ seconds: TimeInterval
    ) -> String {

        let totalSeconds = Int(seconds)

        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60

        return String(
            format: "%d:%02d",
            minutes,
            remainingSeconds
        )
    }

    private func formatPace(
        _ minutesPerKm: Double
    ) -> String {

        let totalSeconds = Int(
            minutesPerKm * 60
        )

        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(
            format: "%d:%02d",
            minutes,
            seconds
        )
    }
}
```
