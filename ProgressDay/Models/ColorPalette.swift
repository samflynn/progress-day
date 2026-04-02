import SwiftUI

/// Time-adaptive color palette that shifts based on day progress.
///
/// - Morning (0–33%): Cool blue/teal — calm, fresh start
/// - Midday (33–66%): Warm gold/amber — peak energy
/// - Evening (66–100%): Deep indigo/purple — winding down
struct ColorPalette {

    // MARK: - Phase Colors

    static let morningStart = Color(hue: 0.53, saturation: 0.75, brightness: 0.85) // Teal
    static let morningEnd = Color(hue: 0.55, saturation: 0.65, brightness: 0.95)   // Bright blue

    static let middayStart = Color(hue: 0.12, saturation: 0.80, brightness: 0.95)  // Warm gold
    static let middayEnd = Color(hue: 0.08, saturation: 0.85, brightness: 0.90)    // Amber

    static let eveningStart = Color(hue: 0.75, saturation: 0.60, brightness: 0.80) // Indigo
    static let eveningEnd = Color(hue: 0.80, saturation: 0.70, brightness: 0.65)   // Deep purple

    // MARK: - Track (Background) Color

    static func trackColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.06)
    }

    // MARK: - Gradient for Progress

    /// Returns an angular gradient suitable for the progress ring at the given progress.
    static func ringGradient(for progress: Double) -> AngularGradient {
        let colors = gradientColors(for: progress)
        return AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * progress)
        )
    }

    /// Returns the primary (leading) color for the current progress.
    static func primaryColor(for progress: Double) -> Color {
        let colors = gradientColors(for: progress)
        return colors.last ?? morningStart
    }

    /// Returns the pair of gradient colors for the current progress.
    static func gradientColors(for progress: Double) -> [Color] {
        let clamped = min(max(progress, 0), 1)

        if clamped < 0.33 {
            let t = clamped / 0.33
            return [
                interpolate(morningStart, morningEnd, t: t),
                interpolate(morningEnd, middayStart, t: t * 0.3)
            ]
        } else if clamped < 0.66 {
            let t = (clamped - 0.33) / 0.33
            return [
                interpolate(morningEnd, middayStart, t: t),
                interpolate(middayStart, middayEnd, t: t)
            ]
        } else {
            let t = (clamped - 0.66) / 0.34
            return [
                interpolate(middayEnd, eveningStart, t: t),
                interpolate(eveningStart, eveningEnd, t: t)
            ]
        }
    }

    // MARK: - Color Interpolation

    private static func interpolate(_ c1: Color, _ c2: Color, t: Double) -> Color {
        let t = min(max(t, 0), 1)
        let r1 = NSColor(c1).usingColorSpace(.sRGB) ?? NSColor(c1)
        let r2 = NSColor(c2).usingColorSpace(.sRGB) ?? NSColor(c2)

        var r1r: CGFloat = 0, r1g: CGFloat = 0, r1b: CGFloat = 0, r1a: CGFloat = 0
        var r2r: CGFloat = 0, r2g: CGFloat = 0, r2b: CGFloat = 0, r2a: CGFloat = 0

        r1.getRed(&r1r, green: &r1g, blue: &r1b, alpha: &r1a)
        r2.getRed(&r2r, green: &r2g, blue: &r2b, alpha: &r2a)

        return Color(
            red: r1r + (r2r - r1r) * t,
            green: r1g + (r2g - r1g) * t,
            blue: r1b + (r2b - r1b) * t,
            opacity: r1a + (r2a - r1a) * t
        )
    }
}
