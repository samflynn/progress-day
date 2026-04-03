import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var manager: ScheduleManager
    @AppStorage("menuBarDisplayMode") private var displayMode: MenuBarDisplayMode = .iconOnly
    @State private var launchAtLogin = false
    @State private var startTime = Date()
    @State private var endTime = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Day range
            HStack {
                Text("Start")
                    .foregroundStyle(.secondary)
                Spacer()
                BorderlessDatePicker(selection: $startTime)
                    .scaleEffect(0.85, anchor: .trailing)
                    .onChange(of: startTime) { _, _ in applyTimes() }
            }

            HStack {
                Text("End")
                    .foregroundStyle(.secondary)
                Spacer()
                BorderlessDatePicker(selection: $endTime)
                    .scaleEffect(0.85, anchor: .trailing)
                    .onChange(of: endTime) { _, _ in applyTimes() }
            }

            Divider().opacity(0.5)

            Picker("", selection: $displayMode) {
                ForEach(MenuBarDisplayMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

            HStack {
                Text("Launch at Login")
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("", isOn: $launchAtLogin)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .scaleEffect(0.7, anchor: .trailing)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
            }

            Divider().opacity(0.5)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .font(.system(size: 11))
        }
        .font(.system(size: 13))
        .padding(14)
        .frame(width: 220)
        .onAppear {
            startTime = timeToDate(hour: manager.startHour, minute: manager.startMinute)
            endTime = timeToDate(hour: manager.endHour, minute: manager.endMinute)
            launchAtLogin = isLaunchAtLoginEnabled()
        }
    }

    // MARK: - Helpers

    private func applyTimes() {
        let calendar = Calendar.current
        let s = calendar.dateComponents([.hour, .minute], from: startTime)
        let e = calendar.dateComponents([.hour, .minute], from: endTime)
        manager.startHour = s.hour ?? 8
        manager.startMinute = s.minute ?? 0
        manager.endHour = e.hour ?? 22
        manager.endMinute = e.minute ?? 0
    }

    private func timeToDate(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var c = calendar.dateComponents([.year, .month, .day], from: Date())
        c.hour = hour
        c.minute = minute
        return calendar.date(from: c) ?? Date()
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error)")
        }
    }

    private func isLaunchAtLoginEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }
}

// MARK: - Borderless Date Picker

struct BorderlessDatePicker: NSViewRepresentable {
    @Binding var selection: Date

    func makeNSView(context: Context) -> NSDatePicker {
        let picker = NSDatePicker()
        picker.datePickerMode = .single
        picker.datePickerElements = .hourMinute
        picker.datePickerStyle = .textField
        picker.isBezeled = false
        picker.isBordered = false
        picker.drawsBackground = false
        picker.dateValue = selection
        picker.target = context.coordinator
        picker.action = #selector(Coordinator.dateChanged(_:))
        picker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return picker
    }

    func updateNSView(_ picker: NSDatePicker, context: Context) {
        picker.dateValue = selection
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    class Coordinator: NSObject {
        var selection: Binding<Date>

        init(selection: Binding<Date>) {
            self.selection = selection
        }

        @objc func dateChanged(_ sender: NSDatePicker) {
            selection.wrappedValue = sender.dateValue
        }
    }
}