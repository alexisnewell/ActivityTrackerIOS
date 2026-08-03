import SwiftUI
struct ExportButton: View {
    let workouts: [Workout]
    let stepHistory: [DailySteps]

    @State private var showOptions = false
    @State private var exportURLs: [URL] = []
    @State private var showExportError = false

    private var hasAnyData: Bool {
        !workouts.isEmpty || !stepHistory.isEmpty
    }
    var body: some View {
        Button {
            showOptions = true
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .disabled(!hasAnyData)
        .confirmationDialog("Export History", isPresented: $showOptions, titleVisibility: .visible) {
            Button("Export Workouts") { export(.workouts) }
                .disabled(workouts.isEmpty)
            Button("Export Steps") { export(.steps) }
                .disabled(stepHistory.isEmpty)
            Button("Export Both") { export(.both) }
                .disabled(workouts.isEmpty && stepHistory.isEmpty)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Couldn't export history", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        }
        .sheet(isPresented: Binding(
            get: { !exportURLs.isEmpty },
            set: { if !$0 { exportURLs = [] } }
        )) {
            ShareSheet(activityItems: exportURLs)
        }
    }
    private enum ExportKind {
        case workouts, steps, both
    }
    private func export(_ kind: ExportKind) {
        var urls: [URL] = []

        if kind == .workouts || kind == .both {
            let csv = CSVExporter.generateWorkoutHistoryCSV(from: workouts)
            if let url = CSVExporter.writeCSVToTempFile(csv, filename: "workout_history.csv") {
                urls.append(url)
            }
        }
        if kind == .steps || kind == .both {
            let csv = CSVExporter.generateStepsHistoryCSV(from: stepHistory)
            if let url = CSVExporter.writeCSVToTempFile(csv, filename: "step_history.csv") {
                urls.append(url)
            }
        }
        guard !urls.isEmpty else {
            showExportError = true
            return
        }
        exportURLs = urls
    }
}
