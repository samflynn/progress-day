import Foundation

enum TimeUtils {

    /// Formats a duration in seconds to a human-readable string.
    /// e.g., 15780 → "4h 23m"
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }

    /// Formats a duration as a short string for the menu bar.
    /// e.g., "4:23" or "23m"
    static func formatDurationShort(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Formats hour/minute to a display string using the user's locale.
    /// e.g., 14:30 → "2:30 PM" or "14:30"
    static func formatTime(hour: Int, minute: Int) -> String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = calendar.date(from: components) ?? Date()

        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "j:mm",
            options: 0,
            locale: Locale.current
        )
        return formatter.string(from: date)
    }

    /// Returns the current time formatted for display.
    static func currentTimeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "j:mm",
            options: 0,
            locale: Locale.current
        )
        return formatter.string(from: Date())
    }
}
