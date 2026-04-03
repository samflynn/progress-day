import SwiftUI

@main
struct ProgressDayApp: App {
    @StateObject private var scheduleManager = ScheduleManager()
    @AppStorage("menuBarDisplayMode") private var displayMode: MenuBarDisplayMode = .iconOnly

    var body: some Scene {
        MenuBarExtra {
            SettingsView(manager: scheduleManager)
        } label: {
            MenuBarLabel(manager: scheduleManager, displayMode: displayMode)
        }
        .menuBarExtraStyle(.window)
    }
}

enum MenuBarDisplayMode: String, CaseIterable, Identifiable {
    case iconOnly = "Icon Only"
    case iconAndPercentage = "Icon + Percentage"
    case iconAndTimeRemaining = "Icon + Time Remaining"

    var id: String { rawValue }
}
