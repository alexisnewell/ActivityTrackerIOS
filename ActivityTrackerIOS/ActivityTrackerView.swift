//
//  ActivityTrackerView.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-15.
//

import CoreLocation
import SwiftUI
import CoreMotion
import SwiftData

struct ActivityTrackerView: View {

    @StateObject private var tracker = ActivityTracker()
    @Environment(\.modelContext) private var context

    @State private var selectedType: ActivityType = .run
    @State private var isTracking = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                titleView
                typePicker
                if tracker.authorizationDenied {
                    Text("Location access is required to track distance. Enable it in Settings.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        RunningPRsView()
                    } label: {
                        Image(systemName: "trophy")
                    }
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
            durationSeconds: tracker.elapsedSeconds,
            splitSecondsByDistance: tracker.splitSecondsByDistance
        )
        context.insert(record)
        try? context.save()

        tracker.reset()
    }
}

/// Tracks distance via GPS (CoreLocation) instead of stride-length estimation,
/// step count from CMPedometer, elapsed time, and per-distance split times
/// recorded the moment each standard distance is crossed mid-run.
@MainActor
final class ActivityTracker: NSObject, ObservableObject {
    @Published var steps: Int = 0
    @Published var elapsedSeconds: Int = 0
    @Published var distanceMiles: Double = 0
    @Published var authorizationDenied = false

    private let pedometer = CMPedometer()
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var sessionStart = Date()
    private var timer: Timer?

    private(set) var splitSecondsByDistance: [String: Int] = [:]
    private var remainingDistances = StandardDistances.all

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
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
        distanceMiles = 0
        lastLocation = nil
        splitSecondsByDistance = [:]
        remainingDistances = StandardDistances.all

        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            authorizationDenied = true
        } else {
            locationManager.startUpdatingLocation()
        }

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
                guard let self else { return }
                self.elapsedSeconds += 1
                self.checkSplits()
            }
        }
    }

    func stop() {
        pedometer.stopUpdates()
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        steps = 0
        elapsedSeconds = 0
        distanceMiles = 0
        lastLocation = nil
        splitSecondsByDistance = [:]
        remainingDistances = StandardDistances.all
    }

    private func checkSplits() {
        while let next = remainingDistances.first, distanceMiles >= next.miles {
            splitSecondsByDistance[next.name] = elapsedSeconds
            remainingDistances.removeFirst()
        }
    }
}

extension ActivityTracker: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        Task { @MainActor in
            guard newLocation.horizontalAccuracy >= 0, newLocation.horizontalAccuracy < 20 else { return }

            if let last = self.lastLocation {
                let metersDelta = newLocation.distance(from: last)
                self.distanceMiles += metersDelta / 1609.34
                self.checkSplits()
            }
            self.lastLocation = newLocation
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.startUpdatingLocation()
            } else if status == .denied || status == .restricted {
                self.authorizationDenied = true
            }
        }
    }
}

#Preview {
    ActivityTrackerView()
}
