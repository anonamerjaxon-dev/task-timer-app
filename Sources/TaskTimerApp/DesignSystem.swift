import SwiftUI

// MARK: - Design System for Minimalistic Black Theme (OLED Optimized)

/// Centralized design system for consistent, minimalistic black theme UI
/// Optimized for OLED displays with pure blacks and high contrast
struct DesignSystem {

    // MARK: - Colors (OLED-Optimized Black Theme)
    struct Colors {
        // Primary colors - Pure black OLED optimization
        static let background = Color.black // Pure black for OLED power saving
        static let surface = Color(white: 0.05) // Very dark gray, almost black
        static let surfaceLight = Color(white: 0.08) // Slightly lighter for cards
        static let surfaceLighter = Color(white: 0.12) // For elevated surfaces

        // Floating timer colors - subtle dark theme
        static let floatingTimerBackground = Color(white: 0.03)
        static let floatingTimerBackgroundAlt = Color(white: 0.06)
        static let floatingTimerBorder = Color(white: 0.15)

        // Text colors - Maximum contrast for OLED readability
        static let textPrimary = Color.white // Pure white for maximum contrast
        static let textSecondary = Color(white: 0.85) // High contrast secondary
        static let textTertiary = Color(white: 0.65) // Medium contrast
        static let textQuaternary = Color(white: 0.45) // For disabled states

        // Accent colors - Monochromatic white/gray for minimalism
        static let accent = Color.white
        static let accentSecondary = Color(white: 0.9)
        static let accentTertiary = Color(white: 0.75)

        // Priority colors - Muted but visible on black background
        static let priorityHigh = Color(red: 0.9, green: 0.3, blue: 0.3) // Muted red
        static let priorityMedium = Color(red: 0.9, green: 0.6, blue: 0.2) // Muted orange
        static let priorityLow = Color(red: 0.3, green: 0.8, blue: 0.4) // Muted green

        // Status colors - High contrast on black
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
        static let warning = Color(red: 0.9, green: 0.6, blue: 0.2) // Orange
        static let error = Color(red: 0.9, green: 0.3, blue: 0.3) // Red

        // Interactive states - Subtle variations on black
        static let interactive = Color(white: 0.1)
        static let interactiveHover = Color(white: 0.15)
        static let interactivePressed = Color(white: 0.2)
        static let interactiveDisabled = Color(white: 0.06)

        // Timer-specific colors - Subtle accents
        static let timerActive = Color(red: 0.2, green: 0.7, blue: 0.9) // Soft blue
        static let timerBreak = Color(red: 0.3, green: 0.8, blue: 0.5) // Soft green
        static let timerPaused = Color(red: 0.9, green: 0.6, blue: 0.2) // Soft orange

        // Card and container colors
        static let cardBackground = Color(white: 0.04) // Very subtle elevation
        static let divider = Color(white: 0.12) // Subtle dividers
    }

    // MARK: - Typography (Inter-inspired system font)
    struct Typography {
        // Minimalist type scale with Swiss-style hierarchy
        static let largeTitle = Font.system(size: 34, weight: .light, design: .default)
        static let title1 = Font.system(size: 28, weight: .light, design: .default)
        static let title2 = Font.system(size: 22, weight: .light, design: .default)
        static let title3 = Font.system(size: 20, weight: .medium, design: .default)
        static let headline = Font.system(size: 18, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let callout = Font.system(size: 15, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .medium, design: .default)
        static let caption1 = Font.system(size: 12, weight: .medium, design: .default)
        static let caption2 = Font.system(size: 11, weight: .medium, design: .default)

        // Additional sizes for better hierarchy
        static let tiny = Font.system(size: 10, weight: .medium, design: .default)

        // Timer specific - Ultra minimal, large display
        static let timerLarge = Font.system(size: 56, weight: .ultraLight, design: .default)
        static let timerMedium = Font.system(size: 24, weight: .light, design: .default)
        static let timerSmall = Font.system(size: 18, weight: .light, design: .default)

        // Monospaced for numbers - Clean timer display
        static let monospacedLarge = Font.system(size: 56, weight: .ultraLight, design: .monospaced)
        static let monospacedMedium = Font.system(size: 18, weight: .regular, design: .monospaced)
        static let monospacedSmall = Font.system(size: 14, weight: .regular, design: .monospaced)
    }

    // MARK: - Spacing (8pt grid system)
    struct Spacing {
        // Minimalist spacing scale - generous whitespace
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64

        // Additional spacing for specific use cases
        static let quarter: CGFloat = 2
        static let half: CGFloat = 6
        static let oneAndHalf: CGFloat = 12
        static let twoAndHalf: CGFloat = 20
    }

    // MARK: - Corner Radius (Minimal, consistent)
    struct CornerRadius {
        // Minimal corner radius - subtle rounding
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 14
        static let xlarge: CGFloat = 18
        static let circle: CGFloat = 999

        // Subtle radius for minimal elements
        static let subtle: CGFloat = 4
    }

    // MARK: - Line Widths (Thicker for better visibility)
    struct LineWidth {
        static let hairline: CGFloat = 0.5
        static let thin: CGFloat = 1.0
        static let regular: CGFloat = 1.5  // Increased from typical 1.0
        static let medium: CGFloat = 2.0   // Increased
        static let thick: CGFloat = 3.0    // Increased
        static let bold: CGFloat = 4.0     // New for emphasis
    }

    // MARK: - Animation (Subtle, fast)
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.12)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.3)
    }

    // MARK: - Shadows (Minimal for dark theme)
    struct Shadows {
        static let subtle = Color.black.opacity(0.2)
        static let medium = Color.black.opacity(0.4)
        static let strong = Color.black.opacity(0.6)
    }
}

// MARK: - View Modifiers for Consistent Styling

/// Minimal button style for clean, black theme
struct MinimalButtonStyle: ButtonStyle {
    let variant: Variant
    let size: ButtonSize

    enum Variant {
        case primary
        case secondary
        case destructive
        case ghost
        case success
    }

    enum ButtonSize {
        case small
        case medium
        case large

        var padding: (horizontal: CGFloat, vertical: CGFloat) {
            switch self {
            case .small:
                return (DesignSystem.Spacing.sm, DesignSystem.Spacing.xs)
            case .medium:
                return (DesignSystem.Spacing.md, DesignSystem.Spacing.sm)
            case .large:
                return (DesignSystem.Spacing.lg, DesignSystem.Spacing.md)
            }
        }

        var font: Font {
            switch self {
            case .small:
                return DesignSystem.Typography.caption1
            case .medium:
                return DesignSystem.Typography.subheadline
            case .large:
                return DesignSystem.Typography.callout
            }
        }
    }

    init(variant: Variant, size: ButtonSize = .medium) {
        self.variant = variant
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .fontWeight(.medium)
            .foregroundColor(textColor)
            .padding(.horizontal, size.padding.horizontal)
            .padding(.vertical, size.padding.vertical)
            .frame(minHeight: 44)
            .background(backgroundColor(for: configuration))
            .cornerRadius(DesignSystem.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }

    private var textColor: Color {
        switch variant {
        case .primary: return DesignSystem.Colors.background
        case .secondary: return DesignSystem.Colors.textPrimary
        case .ghost: return DesignSystem.Colors.textSecondary
        case .destructive: return DesignSystem.Colors.error
        case .success: return DesignSystem.Colors.success
        }
    }

    private func backgroundColor(for configuration: Configuration) -> Color {
        let baseColor: Color
        switch variant {
        case .primary: baseColor = DesignSystem.Colors.accent
        case .secondary: baseColor = DesignSystem.Colors.interactive
        case .destructive: baseColor = DesignSystem.Colors.error.opacity(0.1)
        case .ghost: baseColor = Color.clear
        case .success: baseColor = DesignSystem.Colors.success.opacity(0.1)
        }

        if configuration.isPressed {
            return baseColor.opacity(0.8)
        }
        return baseColor
    }

    private var borderColor: Color {
        switch variant {
        case .primary, .ghost: return Color.clear
        case .secondary: return DesignSystem.Colors.divider
        case .destructive: return DesignSystem.Colors.error.opacity(0.2)
        case .success: return DesignSystem.Colors.success.opacity(0.2)
        }
    }

    private var borderWidth: CGFloat {
        switch variant {
        case .primary, .ghost: return 0
        case .secondary, .destructive, .success: return DesignSystem.LineWidth.medium // Thicker borders
        }
    }
}

/// Minimal card style for dark theme
struct CardStyle: ViewModifier {
    let elevated: Bool
    let bordered: Bool

    init(elevated: Bool = false, bordered: Bool = true) {
        self.elevated = elevated
        self.bordered = bordered
    }

    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(bordered ? DesignSystem.Colors.divider : Color.clear, lineWidth: DesignSystem.LineWidth.medium) // Thicker borders
            )
            .shadow(
                color: elevated ? DesignSystem.Shadows.medium : DesignSystem.Shadows.subtle,
                radius: elevated ? 6 : 2,
                x: 0,
                y: elevated ? 2 : 1
            )
    }
}

/// Minimal tab button style for navigation
struct TabButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
            .font(DesignSystem.Typography.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .frame(minWidth: 80, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(isSelected ? DesignSystem.Colors.surfaceLight : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(isSelected ? DesignSystem.Colors.accentSecondary : Color.clear, lineWidth: DesignSystem.LineWidth.regular) // Thicker borders
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Extensions for Easy Usage

extension View {
    func minimalButtonStyle(_ variant: MinimalButtonStyle.Variant = .primary, size: MinimalButtonStyle.ButtonSize = .medium) -> some View {
        buttonStyle(MinimalButtonStyle(variant: variant, size: size))
    }

    func cardStyle(elevated: Bool = false, bordered: Bool = true) -> some View {
        modifier(CardStyle(elevated: elevated, bordered: bordered))
    }

    func tabButtonStyle(isSelected: Bool) -> some View {
        buttonStyle(TabButtonStyle(isSelected: isSelected))
    }

    // New utility modifiers for better spacing and layout
    func sectionPadding() -> some View {
        padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
    }

    func contentPadding() -> some View {
        padding(DesignSystem.Spacing.md)
    }

    func cardPadding() -> some View {
        padding(DesignSystem.Spacing.sm)
    }
}

// MARK: - Simple Clock Icon Component
struct ClockIcon: View {
    let size: CGFloat
    let color: Color

    init(size: CGFloat = 16, color: Color = DesignSystem.Colors.textPrimary) {
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            // Clock circle
            Circle()
                .stroke(color, lineWidth: DesignSystem.LineWidth.regular) // Thicker
                .frame(width: size, height: size)

            // Clock hands
            Rectangle()
                .fill(color)
                .frame(width: DesignSystem.LineWidth.medium, height: size * 0.3) // Thicker
                .offset(y: -size * 0.15)

            Rectangle()
                .fill(color)
                .frame(width: DesignSystem.LineWidth.regular, height: size * 0.2) // Thicker
                .offset(x: size * 0.1, y: -size * 0.1)

            // Center dot
            Circle()
                .fill(color)
                .frame(width: DesignSystem.LineWidth.bold, height: DesignSystem.LineWidth.bold) // Bigger
        }
    }
}
