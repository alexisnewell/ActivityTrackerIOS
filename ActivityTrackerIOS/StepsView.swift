//
//  StepsView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-01.
//

import SwiftUI
import CoreMotion
import SwiftData

/// SwiftUI equivalent of MainActivity.java.
struct StepsView: View {
    
    @StateObject private var motion = MotionTracker()
    @Environment(\.modelContext) private var context
    @State private var goal: Int = UserDefaults.standard.integer(forKey: "step_goal") == 0
    ? 10000
    : UserDefaults.standard.integer(forKey: "step_goal")
    @State private var showGoalEditor = false
    @State private var goalInputText = ""
    @State private var hasCelebratedGoalToday = false
    @State private var showGoalReachedAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                titleView
                GoalView
                Spacer()
                stepsView
                Spacer()
                historyButton
                Spacer()
            }
            .padding()
            .onAppear {
                motion.start()
            }
            .onDisappear {
                motion.stop()
                saveTodaySteps()
            }
            .onChange(of: motion.steps) { _, newValue in
                checkGoalReached(steps: newValue)
            }
            .alert("Set Step Goal", isPresented: $showGoalEditor) {
                TextField("Goal", text: $goalInputText)
                    .keyboardType(.numberPad)
                Button("Cancel", role: .cancel) {}
                Button("Save") { saveGoal() }
            }
            .alert("Goal Reached! 🎉", isPresented: $showGoalReachedAlert) {
                Button("Nice!", role: .cancel) {}
            } message: {
                Text("You hit your goal of \(goal) steps today.")
            }
        }
    }

    private var stepsView: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 14)

            Circle()
                .trim(from: 0, to: progressFraction)
                .stroke(
                    progressFraction >= 1.0 ? Color.green : Color.blue,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progressFraction)

            VStack(spacing: 4) {
                Text("Steps").font(.caption).foregroundColor(.gray)
                Text("\(motion.steps)")
                    .font(.system(size: 48, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .padding(24)
        }
        .frame(width: 220, height: 220)
    }

    private var progressFraction: Double {
        guard goal > 0 else { return 0 }
        return min(Double(motion.steps) / Double(goal), 1.0)
    }
    private var titleView: some View {
        Text("Total Steps")
            .font(.title).bold()
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }
    
    private var GoalView: some View {
        VStack(spacing: 4) {
            Text("Goal: \(goal)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Edit Goal") {
                goalInputText = String(goal)
                showGoalEditor = true
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
    }
    
    private func saveGoal() {
        guard let newGoal = Int(goalInputText), newGoal > 0 else { return }
        goal = newGoal
        UserDefaults.standard.set(newGoal, forKey: "step_goal")
        hasCelebratedGoalToday = false // allow re-celebrating if they raise the goal past current steps
    }

    private func checkGoalReached(steps: Int) {
        guard steps >= goal, !hasCelebratedGoalToday else { return }
        hasCelebratedGoalToday = true
        showGoalReachedAlert = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private var historyButton: some View {
        NavigationLink {
            StepHistoryView()
        } label: {
            Label("Step History", systemImage: "clock.arrow.circlepath")
        }
        .buttonStyle(.borderedProminent)
    }

    /// Persists (or updates) today's step count into SwiftData so it shows up
    /// in Step History and can be exported. Called whenever the user leaves this screen.
    private func saveTodaySteps() {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailySteps>(
            predicate: #Predicate { $0.date == today }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.steps = motion.steps
        } else {
            let entry = DailySteps(date: today, steps: motion.steps)
            context.insert(entry)
        }
        try? context.save()
    }
}

/// Replaces the JNI bridge (nativeInit/nativeGetSteps/nativeGetPitch/etc.)
/// and the 200ms poll loop from MainActivity.java. CoreMotion pushes updates
/// to us instead of us polling native state every 200ms.
@MainActor
final class MotionTracker: ObservableObject {
    @Published var steps: Int = 0
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var carryModeLabel: String = "Unknown ❓"

    private let pedometer = CMPedometer()
    private let motionManager = CMMotionManager()
    private var stepsBaseline: Int = 0   // supports "Reset Steps" without a hardware reset
    private var sessionStart = Date()

    func start() {
        sessionStart = Date()
        stepsBaseline = 0

        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: sessionStart) { [weak self] data, error in
                guard let self, let data, error == nil else { return }
                Task { @MainActor in
                    self.steps = data.numberOfSteps.intValue - self.stepsBaseline
                }
            }
        }

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.2 // matches the original 200ms poll cadence
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
                guard let self, let motionData, error == nil else { return }
                self.pitch = motionData.attitude.pitch * 180 / .pi
                self.roll = motionData.attitude.roll * 180 / .pi
            }
        }
    }

    func stop() {
        pedometer.stopUpdates()
        motionManager.stopDeviceMotionUpdates()
    }

    /// CMPedometer has no hardware reset — instead, restart the query from now
    /// and track a baseline offset so displayed steps go back to 0.
    func resetSteps() {
        pedometer.stopUpdates()
        sessionStart = Date()
        stepsBaseline = 0
        steps = 0
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: sessionStart) { [weak self] data, error in
                guard let self, let data, error == nil else { return }
                Task { @MainActor in
                    self.steps = data.numberOfSteps.intValue - self.stepsBaseline
                }
            }
        }
    }
}

#Preview {
    StepsView()
}
