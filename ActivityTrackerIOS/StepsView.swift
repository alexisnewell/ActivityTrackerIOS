//
//  StepsView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-01.
//

import SwiftUI
import CoreMotion

/// SwiftUI equivalent of MainActivity.java.
///
/// Key architectural difference from the Android version:
/// - No JNI / C++ bridge, no sensor_bridge.cpp, no StepDetector, no OrientationFilter.
/// - Step counting uses CMPedometer, which reads Apple's hardware motion
///   coprocessor directly — more accurate and far more battery-efficient
///   than hand-rolled peak detection, and it works even when the app isn't running.
/// - Pitch/roll use CMMotionManager's deviceMotion, which already applies
///   Apple's own sensor fusion (a full attitude estimator) — this replaces
///   OrientationFilter's complementary filter with a built-in equivalent.
/// - Carry mode (hand/pocket/bag) has no built-in iOS equivalent — CoreMotion
///   doesn't expose this. Left as "Unknown" for now; would need a custom
///   classifier ported from StepDetector's threshold logic if you want it back.
struct StepsView: View {

    @StateObject private var motion = MotionTracker()

    var body: some View {
        VStack(spacing: 12) {
            titleView
            stepsView
            orientationView
            resetButton
            Spacer()
        }
        .padding()
        .onAppear { motion.start() }
        .onDisappear { motion.stop() }
    }

    private var titleView: some View {
        Text("Steps")
            .font(.title2).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stepsView: some View {
        VStack(spacing: 4) {
            Text("Steps").font(.caption).foregroundColor(.gray)
            Text("\(motion.steps)")
                .font(.system(size: 64, weight: .bold))
        }
    }

    private var orientationView: some View {
        HStack(spacing: 32) {
            VStack {
                Text("Pitch").font(.caption).foregroundColor(.gray)
                Text(String(format: "%.1f°", motion.pitch))
                    .font(.title2).bold()
                    .foregroundColor(.blue)
            }
            VStack {
                Text("Roll").font(.caption).foregroundColor(.gray)
                Text(String(format: "%.1f°", motion.roll))
                    .font(.title2).bold()
                    .foregroundColor(.blue)
            }
        }
    }

    private var resetButton: some View {
        Button("Reset Steps") {
            motion.resetSteps()
        }
        .buttonStyle(.bordered)
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
