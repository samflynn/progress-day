import Foundation
import SwiftUI
import Combine

struct DaySchedule {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int

    /// Whether the end time is past midnight (e.g., 2 AM next day)
    var crossesMidnight: Bool {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        return endMinutes <= startMinutes
    }

    /// Total duration of the day in seconds
    var totalDuration: TimeInterval {
        let startMinutes = startHour * 60 + startMinute
        var endMinutes = endHour * 60 + endMinute
        if crossesMidnight {
            endMinutes += 24 * 60
        }
        return TimeInterval((endMinutes - startMinutes) * 60)
    }

    /// Start time as a Date for today
    func startDate(relativeTo now: Date = Date()) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = startHour
        components.minute = startMinute
        components.second = 0
        return calendar.date(from: components) ?? now
    }

    /// End time as a Date (may be tomorrow if crosses midnight)
    func endDate(relativeTo now: Date = Date()) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = endHour
        components.minute = endMinute
        components.second = 0
        var date = calendar.date(from: components) ?? now
        if crossesMidnight {
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return date
    }

    /// Current progress as a fraction 0.0–1.0, clamped
    func progress(at now: Date = Date()) -> Double {
        let start = startDate(relativeTo: now)
        let end = endDate(relativeTo: now)

        // Handle the case where we're past midnight but before end time
        let adjustedStart = start
        if crossesMidnight && now < start {
            // We might be in the post-midnight portion; check if yesterday's start applies
            let calendar = Calendar.current
            let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: start)!
            let yesterdayEnd = calendar.date(byAdding: .day, value: -1, to: end)!
            if now >= yesterdayStart && now <= yesterdayEnd {
                return now.timeIntervalSince(yesterdayStart) / yesterdayStart.distance(to: yesterdayEnd)
            }
        }

        let elapsed = now.timeIntervalSince(adjustedStart)
        let total = adjustedStart.distance(to: end)

        guard total > 0 else { return 0 }
        return min(max(elapsed / total, 0), 1)
    }

    /// Time remaining from now until end
    func timeRemaining(at now: Date = Date()) -> TimeInterval {
        let end = endDate(relativeTo: now)
        let remaining = end.timeIntervalSince(now)

        if crossesMidnight && remaining > totalDuration {
            // We haven't started yet today
            let calendar = Calendar.current
            let yesterdayEnd = calendar.date(byAdding: .day, value: -1, to: end)!
            let yesterdayRemaining = yesterdayEnd.timeIntervalSince(now)
            if yesterdayRemaining > 0 {
                return yesterdayRemaining
            }
        }

        return max(remaining, 0)
    }

    /// Whether the current time falls within the scheduled day
    func isActive(at now: Date = Date()) -> Bool {
        let p = progress(at: now)
        return p > 0 && p < 1
    }

    /// Whether the day hasn't started yet
    func hasNotStarted(at now: Date = Date()) -> Bool {
        return progress(at: now) <= 0
    }

    /// Whether the day has ended
    func hasEnded(at now: Date = Date()) -> Bool {
        return progress(at: now) >= 1
    }
}

// MARK: - Schedule Manager (Observable)

class ScheduleManager: ObservableObject {
    @Published var progress: Double = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isActive: Bool = true
    @Published var hasEnded: Bool = false
    @Published var hasNotStarted: Bool = false

    @AppStorage("dayStartHour") var startHour: Int = 8 {
        didSet { update() }
    }
    @AppStorage("dayStartMinute") var startMinute: Int = 0 {
        didSet { update() }
    }
    @AppStorage("dayEndHour") var endHour: Int = 22 {
        didSet { update() }
    }
    @AppStorage("dayEndMinute") var endMinute: Int = 0 {
        didSet { update() }
    }

    var schedule: DaySchedule {
        DaySchedule(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute
        )
    }

    private var timer: AnyCancellable?

    init() {
        update()
        timer = Timer.publish(every: 15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
    }

    func update() {
        let now = Date()
        let sched = schedule
        withAnimation(.easeInOut(duration: 1.0)) {
            progress = sched.progress(at: now)
        }
        timeRemaining = sched.timeRemaining(at: now)
        isActive = sched.isActive(at: now)
        hasEnded = sched.hasEnded(at: now)
        hasNotStarted = sched.hasNotStarted(at: now)
        objectWillChange.send()
    }

    /// Formatted time remaining string (e.g., "4h 23m")
    var timeRemainingFormatted: String {
        TimeUtils.formatDuration(timeRemaining)
    }

    /// Formatted percentage string (how much of the day is left)
    var percentageFormatted: String {
        "\(Int(progress * 100))%"
    }

    /// Formatted percentage remaining (how much of the day is left)
    var percentageRemainingFormatted: String {
        "\(Int((1 - progress) * 100))% left"
    }

    /// Formatted start time
    var startTimeFormatted: String {
        TimeUtils.formatTime(hour: startHour, minute: startMinute)
    }

    /// Formatted end time
    var endTimeFormatted: String {
        TimeUtils.formatTime(hour: endHour, minute: endMinute)
    }
}
