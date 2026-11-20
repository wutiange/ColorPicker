import AppKit

enum ColorFormat: String, CaseIterable {
    case hex
    case hexWithAlpha
    case rgb
    case rgba
    case hsl
    case hsla
    case nsColor
    case swiftUIColor

    var menuTitle: String {
        switch self {
        case .hex:
            "HEX"
        case .hexWithAlpha:
            "HEX（含透明度）"
        case .rgb:
            "RGB"
        case .rgba:
            "RGBA"
        case .hsl:
            "HSL"
        case .hsla:
            "HSLA"
        case .nsColor:
            "NSColor（Swift）"
        case .swiftUIColor:
            "SwiftUI Color"
        }
    }

    func string(from color: NSColor) -> String? {
        guard let color = color.usingColorSpace(.sRGB) else { return nil }

        let red = Self.clamped(color.redComponent)
        let green = Self.clamped(color.greenComponent)
        let blue = Self.clamped(color.blueComponent)
        let alpha = Self.clamped(color.alphaComponent)
        let red255 = Int((red * 255).rounded())
        let green255 = Int((green * 255).rounded())
        let blue255 = Int((blue * 255).rounded())
        let alpha255 = Int((alpha * 255).rounded())

        switch self {
        case .hex:
            return String(format: "#%02X%02X%02X", red255, green255, blue255)
        case .hexWithAlpha:
            return String(format: "#%02X%02X%02X%02X", red255, green255, blue255, alpha255)
        case .rgb:
            return "rgb(\(red255), \(green255), \(blue255))"
        case .rgba:
            return "rgba(\(red255), \(green255), \(blue255), \(Self.formatAlpha(alpha)))"
        case .hsl, .hsla:
            let (hue, saturation, lightness) = Self.hslComponents(
                red: red,
                green: green,
                blue: blue
            )
            if self == .hsl {
                return "hsl(\(hue), \(saturation)%, \(lightness)%)"
            }
            return "hsla(\(hue), \(saturation)%, \(lightness)%, \(Self.formatAlpha(alpha)))"
        case .nsColor:
            return String(
                format: "NSColor(srgbRed: %.3f, green: %.3f, blue: %.3f, alpha: %.3f)",
                red,
                green,
                blue,
                alpha
            )
        case .swiftUIColor:
            return String(
                format: "Color(.sRGB, red: %.3f, green: %.3f, blue: %.3f, opacity: %.3f)",
                red,
                green,
                blue,
                alpha
            )
        }
    }

    private static func clamped(_ value: CGFloat) -> Double {
        min(max(Double(value), 0), 1)
    }

    private static func formatAlpha(_ alpha: Double) -> String {
        String(format: "%.2f", alpha)
    }

    private static func hslComponents(
        red: Double,
        green: Double,
        blue: Double
    ) -> (hue: Int, saturation: Int, lightness: Int) {
        let maximum = max(red, green, blue)
        let minimum = min(red, green, blue)
        let delta = maximum - minimum
        let lightness = (maximum + minimum) / 2

        var hue = 0.0
        if delta > 0 {
            if maximum == red {
                hue = 60 * ((green - blue) / delta).truncatingRemainder(dividingBy: 6)
            } else if maximum == green {
                hue = 60 * (((blue - red) / delta) + 2)
            } else {
                hue = 60 * (((red - green) / delta) + 4)
            }
        }

        if hue < 0 {
            hue += 360
        }

        let saturation = delta == 0 ? 0 : delta / (1 - abs(2 * lightness - 1))

        return (
            Int(hue.rounded()) % 360,
            Int((saturation * 100).rounded()),
            Int((lightness * 100).rounded())
        )
    }
}
