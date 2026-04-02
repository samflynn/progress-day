import SwiftUI

/// The label shown in the macOS menu bar: a mini progress ring + optional text.
struct MenuBarLabel: View {
    @ObservedObject var manager: ScheduleManager
    let displayMode: MenuBarDisplayMode

    var body: some View {
        HStack(spacing: 4) {
            menuBarIcon
            menuBarText
        }
        .help(tooltipText)
    }

    private var menuBarIcon: some View {
        // Render a small circular progress as an Image for the menu bar
        Image(systemName: "circle")
            .symbolRenderingMode(.palette)
            .hidden()
            .overlay {
                Canvas { context, size in
                    let inset: CGFloat = 2
                    let rect = CGRect(x: inset, y: inset,
                                      width: size.width - inset * 2,
                                      height: size.height - inset * 2)
                    let lineWidth: CGFloat = 2.0
                    let center = CGPoint(x: rect.midX, y: rect.midY)
                    let radius = min(rect.width, rect.height) / 2 - lineWidth / 2

                    // Track
                    let trackPath = Path { p in
                        p.addArc(center: center, radius: radius,
                                 startAngle: .degrees(0), endAngle: .degrees(360),
                                 clockwise: false)
                    }
                    context.stroke(trackPath, with: .color(.primary.opacity(0.2)),
                                   style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                    // Progress arc
                    let progress = min(max(manager.progress, 0), 1)
                    if progress > 0 {
                        let progressPath = Path { p in
                            p.addArc(center: center, radius: radius,
                                     startAngle: .degrees(-90),
                                     endAngle: .degrees(-90 + 360 * progress),
                                     clockwise: false)
                        }
                        context.stroke(progressPath, with: .color(.primary),
                                       style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    }
                } // Canvas
            }
    }

    @ViewBuilder
    private var menuBarText: some View {
        switch displayMode {
        case .iconOnly:
            EmptyView()
        case .iconAndPercentage:
            Text(manager.percentageFormatted)
                .font(.system(.body, design: .rounded))
                .monospacedDigit()
        case .iconAndTimeRemaining:
            Text(manager.timeRemainingFormatted)
                .font(.system(.body, design: .rounded))
                .monospacedDigit()
        }
    }

    private var tooltipText: String {
        if manager.hasNotStarted {
            return "Day starts at \(manager.startTimeFormatted)"
        } else if manager.hasEnded {
            return "Day complete"
        } else {
            return "\(manager.timeRemainingFormatted) remaining (\(manager.percentageFormatted))"
        }
    }
}
