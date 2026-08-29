import SwiftUI

struct WorkoutCalendarView: View {

    let workouts: [Workout]
    @State private var programs: [Program] = []

    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    private var monthTitle: String {
        selectedDate.formatted(
            .dateTime
                .month(.wide)
                .year()
        )
    }

    private var monthDays: [Date] {
        guard let firstDay = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: selectedDate
            )
        ),
        let range = calendar.range(
            of: .day,
            in: .month,
            for: selectedDate
        ) else {
            return []
        }

        return range.compactMap {
            calendar.date(
                byAdding: .day,
                value: $0 - 1,
                to: firstDay
            )
        }
    }

    private var firstWeekdayOffset: Int {

        guard let firstDay = monthDays.first else {
            return 0
        }

        // Calendar weekday is Sunday = 1
        return calendar.component(
            .weekday,
            from: firstDay
        ) - 1
    }

    private var selectedDayWorkouts: [Workout] {

        workouts.filter {
            calendar.isDate(
                $0.date,
                inSameDayAs: selectedDate
            )
        }
    }
    
    private var selectedDayPrograms: [Program] {

        programs.filter { program in

            guard let scheduledDate = program.scheduledDate else {
                return false
            }

            return calendar.isDate(
                scheduledDate,
                inSameDayAs: selectedDate
            )
        }
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            // Month header
            HStack {

                Text(monthTitle)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 18) {

                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }

                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                }
            }

            // Weekday headers
            HStack {

                ForEach(
                    calendar.shortWeekdaySymbols,
                    id: \.self
                ) { day in

                    Text(day.prefix(2))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible()),
                    count: 7
                ),
                spacing: 10
            ) {

                // Empty spaces before first day
                ForEach(
                    0..<firstWeekdayOffset,
                    id: \.self
                ) { _ in

                    Color.clear
                        .frame(height: 40)
                }

                ForEach(
                    monthDays,
                    id: \.self
                ) { date in

                    calendarDay(date)
                }
            }

            Divider()
                .background(Color.gray.opacity(0.4))

            // Workout preview
            workoutPreview
        }
        .onAppear {
            programs = ProgramStore.load()
        }
        .padding(18)
        .background(Color(white: 0.08))
        .cornerRadius(18)
    }

    @ViewBuilder
    private func calendarDay(_ date: Date) -> some View {

        let hasCompletedWorkout = workouts.contains {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
        }

        let hasPlannedWorkout = programs.contains { program in

            guard let scheduledDate = program.scheduledDate else {
                return false
            }

            return calendar.isDate(
                scheduledDate,
                inSameDayAs: date
            )
        }

        let hasWorkout =
            hasCompletedWorkout ||
            hasPlannedWorkout

        let isSelected = calendar.isDate(
            date,
            inSameDayAs: selectedDate
        )

        let isToday = calendar.isDateInToday(date)

        Button {
            selectedDate = date
        } label: {

            VStack(spacing: 4) {

                Text(
                    "\(calendar.component(.day, from: date))"
                )
                .font(.subheadline)
                .bold()
                .foregroundColor(
                    isSelected
                        ? .white
                        : isToday
                            ? Color(hex: "8c52ff")
                            : .white
                )
                .frame(width: 34, height: 28)
                .background(
                    isSelected
                        ? Color(hex: "8c52ff")
                        : Color.clear
                )
                .clipShape(Circle())

                // Purple dot for planned workout
                Circle()
                    .fill(
                        hasWorkout
                            ? Color(hex: "8c52ff")
                            : Color.clear
                    )
                    .frame(width: 5, height: 5)
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var workoutPreview: some View {
        if !selectedDayWorkouts.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Completed")
                    .font(.headline)
                    .foregroundColor(.green)

                ForEach(selectedDayWorkouts) { workout in
                    VStack(alignment: .leading) {

                        Text(workout.exerciseName)
                            .foregroundColor(.white)

                        Text(workout.details)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        };
        if !selectedDayPrograms.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Planned")
                    .font(.headline)
                    .foregroundColor(.blue)
                ForEach(selectedDayPrograms) { program in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(program.name)
                            .bold()
                            .foregroundColor(.white)
                        ForEach(program.exercises) { exercise in

                            Text(
                                "\(exercise.exerciseName) • \(exercise.sets)x\(exercise.reps)"
                            )
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                    }
                }
            }

        } else {

            HStack {

                Image(systemName: "calendar")
                    .foregroundColor(.gray)

                Text("No workout planned")
                    .foregroundColor(.gray)

                Spacer()
            }
        }
    }

    private func changeMonth(by value: Int) {

        if let newDate = calendar.date(
            byAdding: .month,
            value: value,
            to: selectedDate
        ) {

            selectedDate = newDate
        }
    }
}
