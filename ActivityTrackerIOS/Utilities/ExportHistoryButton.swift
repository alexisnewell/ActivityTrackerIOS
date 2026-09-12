import SwiftUI

struct ExportButton: View {
    
    let workouts: [Workout]
    let stepHistory: [DailySteps]
    let activityRecords: [ActivityRecord]
    let programs: [Program]
    
    @State private var showDateRange = false
    @State private var showOptions = false
    
    private enum WorkoutStatus {
        case completed
        case planned
        case both
    }
    
    @State private var workoutStatus: WorkoutStatus = .both
    
    @State private var startDate = Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: Date()
    ) ?? Date()
    
    @State private var endDate = Date()
    
    @State private var exportURLs: [URL] = []
    @State private var showExportError = false
    
    private var hasAnyData: Bool {
        !workouts.isEmpty ||
        !stepHistory.isEmpty ||
        !activityRecords.isEmpty
    }
    
    private var hasRunningPRs: Bool {
        !RunningPRCalculator.calculate(
            from: activityRecords
        ).isEmpty
    }
    
    private var hasSelectedWorkoutData: Bool {
        switch workoutStatus {
        case .completed:
            return !filteredWorkouts.isEmpty

        case .planned:
            return !filteredPrograms.isEmpty

        case .both:
            return !filteredWorkouts.isEmpty ||
                   !filteredPrograms.isEmpty
        }
    }
    
    var body: some View {
        
        Button {
            showDateRange = true
        } label: {
            Label(
                "Export",
                systemImage: "square.and.arrow.up"
            )
        }
        .disabled(!hasAnyData)
        
        .sheet(isPresented: $showDateRange) {
            
            NavigationStack {
                
                Form {
                    
                    Section("Export Date Range") {
                        
                        DatePicker(
                            "Start Date",
                            selection: $startDate,
                            displayedComponents: .date
                        )
                        
                        DatePicker(
                            "End Date",
                            selection: $endDate,
                            displayedComponents: .date
                        )
                    }
                    
                    Section("Workout Status") {
                        
                        Picker(
                            "Include",
                            selection: $workoutStatus
                        ) {
                            Text("Completed")
                                .tag(WorkoutStatus.completed)
                            
                            Text("Planned")
                                .tag(WorkoutStatus.planned)
                            
                            Text("Both")
                                .tag(WorkoutStatus.both)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section {
                        Text(
                            "Choose whether to export completed workouts, planned workouts, or both."
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                .navigationTitle("Export History")
                
                .toolbar {
                    
                    ToolbarItem(
                        placement: .cancellationAction
                    ) {
                        Button("Cancel") {
                            showDateRange = false
                        }
                    }
                    
                    ToolbarItem(
                        placement: .confirmationAction
                    ) {
                        Button("Continue") {
                            
                            if startDate <= endDate {
                                
                                showDateRange = false
                                
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.2
                                ) {
                                    showOptions = true
                                }
                            }
                        }
                        .disabled(startDate > endDate)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        
        .confirmationDialog(
            "Export History",
            isPresented: $showOptions,
            titleVisibility: .visible
        ) {
            
            Button("Export Workouts") {
                export(.workouts)
            }
            .disabled(
                !hasSelectedWorkoutData
            )
            
            Button("Export Steps") {
                export(.steps)
            }
            .disabled(
                filteredSteps.isEmpty
            )
            
            Button("Export Running PRs") {
                export(.runningPRs)
            }
            .disabled(
                filteredActivityRecords.isEmpty
            )
            
            Button("Export All") {
                export(.all)
            }
            .disabled(
                !hasFilteredData
            )
            
            Button("Cancel", role: .cancel) {}
        }
        
        .alert(
            "Couldn't export history",
            isPresented: $showExportError
        ) {
            Button("OK", role: .cancel) {}
        }
        
        .sheet(
            isPresented: Binding(
                get: {
                    !exportURLs.isEmpty
                },
                set: {
                    if !$0 {
                        exportURLs = []
                    }
                }
            )
        ) {
            ShareSheet(
                activityItems: exportURLs
            )
        }
    }
    
    private var filteredWorkouts: [Workout] {
        
        workouts.filter { workout in
            isDateInRange(workout.date)
        }
    }
    
    private var filteredPrograms: [Program] {
        programs.filter { program in
            guard let date = program.scheduledDate else {
                return false
            }

            return isDateInRange(date)
        }
    }
    
    private var filteredSteps: [DailySteps] {
        
        stepHistory.filter { steps in
            isDateInRange(steps.date)
        }
    }
    
    private var filteredActivityRecords: [ActivityRecord] {
        
        activityRecords.filter { record in
            isDateInRange(record.date)
        }
    }
    
    private var hasFilteredData: Bool {
        let hasCompleted = !filteredWorkouts.isEmpty
        let hasPlanned = !filteredPrograms.isEmpty

        switch workoutStatus {
        case .completed:
            return hasCompleted ||
                   !filteredSteps.isEmpty ||
                   !filteredActivityRecords.isEmpty

        case .planned:
            return hasPlanned ||
                   !filteredSteps.isEmpty ||
                   !filteredActivityRecords.isEmpty

        case .both:
            return hasCompleted ||
                   hasPlanned ||
                   !filteredSteps.isEmpty ||
                   !filteredActivityRecords.isEmpty
        }
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        
        let calendar = Calendar.current
        
        let start = calendar.startOfDay(
            for: startDate
        )
        
        let end = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(
                for: endDate
            )
        )!
        
        return date >= start && date < end
    }
    
    private enum ExportKind {
        case workouts
        case steps
        case runningPRs
        case all
    }
    
    private func export(_ kind: ExportKind) {
        var urls: [URL] = []
        
        // Workout exports
        if kind == .workouts || kind == .all {
            
            switch workoutStatus {
                
            case .completed:
                let csv = CSVExporter.generateWorkoutHistoryCSV(
                    from: filteredWorkouts
                )
                
                if let url = CSVExporter.writeCSVToTempFile(
                    csv,
                    filename: "completed_workouts.csv"
                ) {
                    urls.append(url)
                }
                
            case .planned:
                let csv = CSVExporter.generatePlannedWorkoutCSV(
                    from: filteredPrograms
                )

                if let url = CSVExporter.writeCSVToTempFile(
                    csv,
                    filename: "planned_workouts.csv"
                ) {
                    urls.append(url)
                }
                
            case .both:
                let completedCSV = CSVExporter.generateWorkoutHistoryCSV(
                    from: filteredWorkouts
                )

                if let url = CSVExporter.writeCSVToTempFile(
                    completedCSV,
                    filename: "completed_workouts.csv"
                ) {
                    urls.append(url)
                }

                let plannedCSV = CSVExporter.generatePlannedWorkoutCSV(
                    from: filteredPrograms
                )

                if let url = CSVExporter.writeCSVToTempFile(
                    plannedCSV,
                    filename: "planned_workouts.csv"
                ) {
                    urls.append(url)
                }
            }
        }
        
        // Steps export
        if kind == .steps || kind == .all {
            let csv = CSVExporter.generateStepsHistoryCSV(
                from: filteredSteps
            )
            
            if let url = CSVExporter.writeCSVToTempFile(
                csv,
                filename: "step_history.csv"
            ) {
                urls.append(url)
            }
        }
        
        // Running PR export
        if kind == .runningPRs || kind == .all {
            let csv = CSVExporter.generateRunningPRsCSV(
                from: filteredActivityRecords
            )
            
            if let url = CSVExporter.writeCSVToTempFile(
                csv,
                filename: "running_prs.csv"
            ) {
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
