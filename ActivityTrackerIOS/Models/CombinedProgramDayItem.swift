import Foundation

/// What was tapped when starting something from a combined program day.
/// A day can offer up to two of these (strength and running), since both
/// can be scheduled on the same day.
enum CombinedProgramDayItem {
    case strength(Program)
    case running(RunningWorkout)
}