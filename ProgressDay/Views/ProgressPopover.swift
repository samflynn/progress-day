import SwiftUI

struct ProgressPopover: View {
    @ObservedObject var manager: ScheduleManager
    @State private var showSettings = false
    @State private var currentTime = TimeUtils.currentTimeFormatted()

    private let timeRefreshTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            if showSettings {
                SettingsView(manager: manager, showSettings: $showSettings)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                mainContent
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSettings)
        .onReceive(timeRefreshTimer) { _ in
            currentTime = TimeUtils.currentTimeFormatted()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 16) {
            // Header with current time and settings gear
            HStack {
                Text(currentTime)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(.horizontal, 4)

            // Progress Ring
            ProgressRing(progress: manager.progress)
                .padding(.vertical, 4)

            // Status content
            if manager.hasNotStarted {
                notStartedView
            } else if manager.hasEnded {
                dayEndedView
            } else {
                activeView
            }

            // Day range footer
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text("\(manager.startTimeFormatted) — \(manager.endTimeFormatted)")
                    .font(.system(.caption, design: .rounded))
            }
            .foregroundStyle(.tertiary)
            .padding(.top, 4)
        }
        .padding(20)
    }

    private var activeView: some View {
        VStack(spacing: 4) {
            Text(manager.timeRemainingFormatted)
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .monospacedDigit()

            Text("remaining")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)

            Text(manager.percentageFormatted)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(ColorPalette.primaryColor(for: manager.progress))
                .padding(.top, 2)
        }
    }

    private var notStartedView: some View {
        VStack(spacing: 4) {
            Text("Day hasn't started")
                .font(.system(size: 20, weight: .medium, design: .rounded))

            Text("Starts at \(manager.startTimeFormatted)")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var dayEndedView: some View {
        VStack(spacing: 4) {
            Text("Day complete")
                .font(.system(size: 20, weight: .medium, design: .rounded))

            Text("100%")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(ColorPalette.primaryColor(for: 1.0))
        }
    }
}


