import SwiftUI

/// A circular progress ring with gradient stroke, glowing head dot, and bloom effect.
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    init(progress: Double, size: CGFloat = 160, lineWidth: CGFloat = 14) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var gradientColors: [Color] {
        ColorPalette.gradientColors(for: clampedProgress)
    }

    private var primaryColor: Color {
        ColorPalette.primaryColor(for: clampedProgress)
    }

    var body: some View {
        ZStack {
            // Track (background circle)
            Circle()
                .stroke(
                    ColorPalette.trackColor(for: colorScheme),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)

            // Progress arc with gradient
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: ringArcColors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * clampedProgress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: primaryColor.opacity(0.3), radius: 8, x: 0, y: 0)

            // Glowing head dot at the leading edge
            if clampedProgress > 0.01 {
                Circle()
                    .fill(Color.white)
                    .frame(width: lineWidth * 0.6, height: lineWidth * 0.6)
                    .shadow(color: primaryColor.opacity(0.8), radius: 6, x: 0, y: 0)
                    .shadow(color: primaryColor.opacity(0.4), radius: 12, x: 0, y: 0)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * clampedProgress - 90))
            }

            // Start cap (covers the flat start of the gradient)
            Circle()
                .fill(gradientColors.first ?? .blue)
                .frame(width: lineWidth, height: lineWidth)
                .offset(y: -size / 2)
                .rotationEffect(.degrees(-90))
                .opacity(clampedProgress > 0.01 ? 1 : 0)
        }
        .frame(width: size + lineWidth, height: size + lineWidth)
    }

    /// Build a smooth multi-stop gradient for the arc
    private var ringArcColors: [Color] {
        guard clampedProgress > 0 else { return [.clear] }

        let steps = 10
        var colors: [Color] = []
        for i in 0...steps {
            let t = Double(i) / Double(steps) * clampedProgress
            let pair = ColorPalette.gradientColors(for: t)
            colors.append(pair.last ?? pair.first ?? .blue)
        }
        return colors
    }
}

// MARK: - Mini Ring for Menu Bar

/// A smaller version of the progress ring for the menu bar icon.
struct MiniProgressRing: View {
    let progress: Double
    let size: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    init(progress: Double, size: CGFloat = 16) {
        self.progress = progress
        self.size = size
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    ColorPalette.trackColor(for: colorScheme),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    LinearGradient(
                        colors: ColorPalette.gradientColors(for: clampedProgress),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}


