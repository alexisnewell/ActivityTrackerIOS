//
//  RunningProgramRecorderView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-30.
//


//
//  RunningProgramRecorderView.swift
//  ActivityTrackerIOS
//

import SwiftUI
import SwiftData

struct RunningProgramRecorderView: View {

    let program: RunningProgram

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @StateObject private var tracker = ActivityTracker()

    @State private var selectedWorkout: RunningWorkout?
    @State private var steps: [RecordingStep] = []
    @State private var currentStepIndex = 0
    @State private var repStartDistanceMiles: Double = 0
    @State private var repStartElapsedSeconds: Int = 0
    @State private var isFinished = false

    private enum RecordingStep {
        case work(interval: RunningInterval, repNumber: Int, totalReps: Int)
        case recovery(seconds: TimeInterval)
    }

    var body: some View {

        NavigationStack {

            Group {

                if isFinished {
                    finishedView
                } else if selectedWorkout != nil {
                    recordingView
                } else {
                    workoutPicker
                }
            }
            .navigationTitle(selectedWorkout?.name ?? program.name)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        tracker.stop()
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: tracker.elapsedSeconds) { _, _ in
            checkProgress()
        }
    }

    // MARK: - Workout Picker

    private var workoutPicker: some View {

        List(program.workouts) { workout in

            Button {
                start(workout: workout)
            } label: {

                VStack(alignment: .leading, spacing: 4) {

                    Text(workout.name)
                        .font(.headline)

                    Text(
                        "\(workout.intervals.count) interval\(workout.intervals.count == 1 ? "" : "s")"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Recording View

    @ViewBuilder
    private var recordingView: some View {

        if let step = steps[safe: currentStepIndex] {

            VStack(spacing: 24) {

                stepHeader(step)

                Text(tracker.elapsedFormatted)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()

                HStack(spacing: 40) {

                    VStack {
                        Text("Distance").font(.caption).foregroundColor(.gray)
                        Text(String(format: "%.2f mi", tracker.distanceMiles))
                            .font(.title2).bold()
                    }

                    VStack {
                        Text("Steps").font(.caption).foregroundColor(.gray)
                        Text("\(tracker.steps)").font(.title2).bold()
                    }
                }

                Spacer()

                Button("Skip to Next") {
                    advance()
                }
                .buttonStyle(.bordered)

                Button("End Workout Early") {
                    finish()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding()

        } else {

            ProgressView()
                .onAppear { finish() }
        }
    }

    private func stepHeader(_ step: RecordingStep) -> some View {

        switch step {

        case .work(let interval, let repNumber, let totalReps):

            return AnyView(

                VStack(spacing: 6) {

                    Text("Rep \(repNumber) of \(totalReps)")
                        .font(.headline)

                    Text(targetDescription(interval))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            )

        case .recovery(let seconds):

            return AnyView(

                VStack(spacing: 6) {

                    Text("Recovery")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Text(formatDuration(seconds))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            )
        }
    }

    private func targetDescription(_ interval: RunningInterval) -> String {

        if let distance = interval.distance {
            return distance >= 1000
                ? String(format: "%.2f km", distance / 1000)
                : String(format: "%.0f m", distance)
        }

        if let duration = interval.duration {
            return formatDuration(duration)
        }

        return ""
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    // MARK: - Finished View

    private var finishedView: some View {

        VStack(spacing: 20) {

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Workout Complete")
                .font(.title2).bold()

            Text(String(format: "%.2f mi in %@", tracker.distanceMiles, tracker.elapsedFormatted))
                .foregroundColor(.secondary)

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Flow Control

    private func start(workout: RunningWorkout) {

        selectedWorkout = workout
        steps = buildSteps(from: workout)
        currentStepIndex = 0

        tracker.reset()
        tracker.start()

        repStartDistanceMiles = tracker.distanceMiles
        repStartElapsedSeconds = tracker.elapsedSeconds
    }

    private func buildSteps(from workout: RunningWorkout) -> [RecordingStep] {

        var result: [RecordingStep] = []

        for interval in workout.intervals {

            guard interval.repetitions > 0 else { continue }

            for rep in 1...interval.repetitions {

                result.append(
                    .work(interval: interval, repNumber: rep, totalReps: interval.repetitions)
                )

                if let recovery = interval.recovery, rep < interval.repetitions {
                    result.append(.recovery(seconds: recovery))
                }
            }
        }

        return result
    }

    private func checkProgress() {

        guard let step = steps[safe: currentStepIndex] else { return }

        switch step {

        case .work(let interval, _, _):

            if let distance = interval.distance {

                let targetMiles = distance / 1609.34
                let repMiles = tracker.distanceMiles - repStartDistanceMiles

                if repMiles >= targetMiles {
                    advance()
                }

            } else if let duration = interval.duration {

                let repElapsed = tracker.elapsedSeconds - repStartElapsedSeconds

                if Double(repElapsed) >= duration {
                    advance()
                }
            }

        case .recovery(let seconds):

            let repElapsed = tracker.elapsedSeconds - repStartElapsedSeconds

            if Double(repElapsed) >= seconds {
                advance()
            }
        }
    }

    private func advance() {

        currentStepIndex += 1
        repStartDistanceMiles = tracker.distanceMiles
        repStartElapsedSeconds = tracker.elapsedSeconds

        if currentStepIndex >= steps.count {
            finish()
        }
    }

    private func finish() {

        guard !isFinished else { return }

        tracker.stop()
        isFinished = true

        // NOTE: adjust this to match your actual ActivityRecord initializer —
        // this assumes the same shape used in ActivityTrackerView.
        let record = ActivityRecord(
            type: .run,
            steps: tracker.steps,
            distanceMiles: tracker.distanceMiles,
            durationSeconds: tracker.elapsedSeconds,
            splitSecondsByDistance: tracker.splitSecondsByDistance
        )
        context.insert(record)
        try? context.save()
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}