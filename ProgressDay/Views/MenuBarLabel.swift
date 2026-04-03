import SwiftUI
import AppKit

/// The label shown in the macOS menu bar: a mini progress ring + optional text.
struct MenuBarLabel: View {
    @ObservedObject var manager: ScheduleManager
    let displayMode: MenuBarDisplayMode

    var body: some View {
        Image(nsImage: renderMenuBarImage())
            .help(tooltipText)
    }

    private func renderMenuBarImage() -> NSImage {
        let iconSize: CGFloat = 16
        let lineWidth: CGFloat = 2.0
        let font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)

        // Determine text to draw
        let text: String? = {
            switch displayMode {
            case .iconOnly: return nil
            case .iconAndPercentage: return manager.percentageFormatted
            case .iconAndTimeRemaining: return manager.timeRemainingFormatted
            }
        }()

        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor
        ]

        let textSize: CGSize = text.map { ($0 as NSString).size(withAttributes: textAttrs) } ?? .zero
        let spacing: CGFloat = text != nil ? 4 : 0
        let totalWidth = iconSize + spacing + textSize.width
        let totalHeight = max(iconSize, textSize.height)

        let image = NSImage(size: NSSize(width: totalWidth, height: totalHeight), flipped: false) { rect in
            // Draw text on the left, vertically centered
            if let text = text {
                let textY = (rect.height - textSize.height) / 2
                let textPoint = NSPoint(x: 0, y: textY)
                (text as NSString).draw(at: textPoint, withAttributes: textAttrs)
            }

            // Draw the ring on the right, vertically centered
            let iconX = textSize.width + spacing
            let iconY = (rect.height - iconSize) / 2
            let iconRect = CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize)
            let inset = lineWidth / 2 + 1
            let drawRect = iconRect.insetBy(dx: inset, dy: inset)
            let center = NSPoint(x: drawRect.midX, y: drawRect.midY)
            let radius = min(drawRect.width, drawRect.height) / 2

            // Track
            let trackPath = NSBezierPath()
            trackPath.appendArc(withCenter: center, radius: radius,
                                startAngle: 0, endAngle: 360)
            trackPath.lineWidth = lineWidth
            trackPath.lineCapStyle = .round
            NSColor.labelColor.withAlphaComponent(0.2).setStroke()
            trackPath.stroke()

            // Progress arc
            let progress = min(max(self.manager.progress, 0), 1)
            if progress > 0 {
                let startAngle: CGFloat = 90
                let endAngle: CGFloat = 90 - (360 * progress)
                let progressPath = NSBezierPath()
                progressPath.appendArc(withCenter: center, radius: radius,
                                       startAngle: startAngle, endAngle: endAngle,
                                       clockwise: true)
                progressPath.lineWidth = lineWidth
                progressPath.lineCapStyle = .round
                NSColor.labelColor.setStroke()
                progressPath.stroke()
            }

            return true
        }
        image.isTemplate = true
        return image
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
