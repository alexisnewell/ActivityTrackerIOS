import SwiftUI
import CoreMotion
import SwiftData

struct ActivityTrackerView: View {

    @StateObject private var tracker = ActivityTracker()
    @Environment(\.modelContext) private var context

    @State private var selectedType: ActivityType = .walk
    @State private var isTracking = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                titleView
                typePicker
                Spacer()
                statsView
                Spacer()
                controlButton
                Spacer()
            }
            .padding()
            .onDisappear {
                if isTracking {
                    stopAndSave()
                }
            }
        }
    }

    private var titleView: some View {
        Text("Track Activity")
            .font(.title).bold()
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var typePicker: some View {
        Picker("Type", selection: $selectedType) {
            ForEach(ActivityType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .disabled(isTracking)
    }

    private var statsView: some View {
        VStack(spacing: 16) {
            Text(tracker.elapsedFormatted)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 40) {
                VStack {
                    Text("Steps").font(.caption).foregroundColor(.gray)
                    Text("\(tracker.steps)").font(.title2).bold()
                }
                VStack {
                    Text("Distance").font(.caption).foregroundColor(.gray)
                    Text(String(format: "%.2f mi", tracker.distanceMiles)).font(.title2).bold()
                }
            }
        }
    }

    private var controlButton: some View {
        Button(isTracking ? "Stop \(selectedType.rawValue)" : "Start \(selectedType.rawValue)") {
            if isTracking {
                stopAndSave()
            } else {
                start()
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        .tint(isTracking ? .red : .blue)
    }

    private func start() {
        isTracking = true
        tracker.start()
    }

    private func stopAndSave() {
        tracker.stop()
        isTracking = false

        let record = ActivityRecord(
            type: selectedType,
            steps: tracker.steps,
            distanceMiles: tracker.distanceMiles,
            durationSeconds: tracker.elapsedSeconds
        )
        context.insert(record)
        try? context.save()

        tracker.reset()
    }
}

/// Same CMPedometer-based step/distance approach as MotionTracker in StepsView,
/// plus a live elapsed-time timer for the activity session.
@MainActor
final class ActivityTracker: ObservableObject {
    @Published var steps: Int = 0
    @Published var elapsedSeconds: Int = 0

    private let pedometer = CMPedometer()
    private var sessionStart = Date()
    private var timer: Timer?

    // Same stride assumption as StepsView's distanceMiles calculation
    var distanceMiles: Double {
        let strideFeet = 2.5
        let feet = Double(steps) * strideFeet
        return feet / 5280
    }

    var elapsedFormatted: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        sessionStart = Date()
        steps = 0
        elapsedSeconds = 0

        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: sessionStart) { [weak self] data, error in
                guard let self, let data, error == nil else { return }
                Task { @MainActor in
                    self.steps = data.numberOfSteps.intValue
                }
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    func stop() {
        pedometer.stopUpdates()
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        steps = 0
        elapsedSeconds = 0
    }
}

#Preview {
    ActivityTrackerView()
}