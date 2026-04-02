import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var manager: ScheduleManager
    @Binding var showSettings: Bool
    @AppStorage("menuBarDisplayMode") private var displayMode: MenuBarDisplayMode = .iconOnly
    @State private var launchAtLogin = false

    // Local state for time pickers
    @State private var startTime = Date()
    @State private var endTime = Date()

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Button {
                    applyTimes()
                    showSettings = false
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Settings")
                    .font(.system(.headline, design: .rounded))

                Spacer()

                // Invisible spacer to balance the back button
                Image(systemName: "chevron.left")
                    .font(.system(size: 14))
                    .hidden()
            }
            .padding(.horizontal, 4)

            Divider()

            // Day range
            VStack(alignment: .leading, spacing: 12) {
                Text("Day Range")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                HStack {
                    Text("Start")
                        .font(.system(.body, design: .rounded))
                    Spacer()
                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(width: 100)
                }

                HStack {
                    Text("End")
                        .font(.system(.body, design: .rounded))
                    Spacer()
                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(width: 100)
                }
            }

            Divider()

            // Display mode
            VStack(alignment: .leading, spacing: 12) {
                Text("Menu Bar")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                Picker("Display", selection: $displayMode) {
                    ForEach(MenuBarDisplayMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(.body, design: .rounded))
            }

            Divider()

            // Launch at login
            Toggle(isOn: $launchAtLogin) {
                Text("Launch at Login")
                    .font(.system(.body, design: .rounded))
            }
            .toggleStyle(.switch)
            .onChange(of: launchAtLogin) { _, newValue in
                setLaunchAtLogin(newValue)
            }

            Spacer()

            // Quit button
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit Progress Day")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)
        }
        .padding(20)
        .onAppear {
            startTime = timeToDate(hour: manager.startHour, minute: manager.startMinute)
            endTime = timeToDate(hour: manager.endHour, minute: manager.endMinute)
            launchAtLogin = isLaunchAtLoginEnabled()
        }
    }

    // MARK: - Helpers

    private func applyTimes() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        manager.startHour = startComponents.hour ?? 8
        manager.startMinute = startComponents.minute ?? 0
        manager.endHour = endComponents.hour ?? 22
        manager.endMinute = endComponents.minute ?? 0
    }

    private func timeToDate(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }

    private func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }
}


