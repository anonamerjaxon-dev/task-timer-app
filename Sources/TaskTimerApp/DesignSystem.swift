import SwiftUI

// MARK: - Design System v2 — Refined Dark Professional Theme

/// Inspired by modern productivity tools (Linear, Things, Raycast)
/// Deep charcoal base with subtle blue accents, generous spacing, soft rounded corners
struct DesignSystem {

    // MARK: - Colors (Refined Dark Professional)
    struct Colors {
        // Background hierarchy — deep charcoal with subtle blue undertone
        static let background = Color(hex: "#0D1117")
        static let sidebar = Color(hex: "#0A0E13")
        static let surfaceLow = Color(hex: "#131820")
        static let surface = Color(hex: "#161B22")
        static let surfaceHigh = Color(hex: "#1C2128")
        static let surfaceHighest = Color(hex: "#21262D")

        // Text colors — warm white hierarchy
        static let textPrimary = Color(hex: "#E6EDF3")
        static let textSecondary = Color(hex: "#8B949E")
        static let textTertiary = Color(hex: "#6E7681")
        static let textDisabled = Color(hex: "#484F58")

        // Accent — soft blue
        static let accent = Color(hex: "#58A6FF")
        static let accentMuted = Color(hex: "#58A6FF").opacity(0.15)
        static let accentStrong = Color(hex: "#79C0FF")

        // Status colors
        static let success = Color(hex: "#3FB950")
        static let successMuted = Color(hex: "#3FB950").opacity(0.15)
        static let warning = Color(hex: "#D29922")
        static let warningMuted = Color(hex: "#D29922").opacity(0.15)
        static let error = Color(hex: "#F85149")
        static let errorMuted = Color(hex: "#F85149").opacity(0.15)

        // Priority colors — refined
        static let priorityHigh = Color(hex: "#F85149")
        static let priorityMedium = Color(hex: "#D29922")
        static let priorityLow = Color(hex: "#58A6FF")

        // Timer-specific
        static let timerFocus = Color(hex: "#58A6FF")
        static let timerBreak = Color(hex: "#3FB950")
        static let timerPaused = Color(hex: "#D29922")

        // Borders & dividers
        static let border = Color(hex: "#30363D")
        static let borderSubtle = Color(hex: "#21262D")
        static let divider = Color(hex: "#21262D")

        // Floating timer
        static let floatingBg = Color(hex: "#0D1117").opacity(0.97)
        static let floatingBorder = Color(hex: "#30363D").opacity(0.6)

        // Glass effect
        static let glassBg = Color(hex: "#161B22").opacity(0.85)
        static let glassBorder = Color.white.opacity(0.06)
    }

    // MARK: - Typography (SF Pro Rounded)
    struct Typography {
        // Display
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)

        // Body
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 15, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 14, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let tiny = Font.system(size: 11, weight: .medium, design: .rounded)

        // Timer
        static let timerLarge = Font.system(size: 64, weight: .thin, design: .rounded)
        static let timerMedium = Font.system(size: 28, weight: .light, design: .rounded)
        static let timerSmall = Font.system(size: 18, weight: .regular, design: .rounded)

        // Monospaced
        static let monoLarge = Font.system(size: 64, weight: .thin, design: .monospaced)
        static let monoMedium = Font.system(size: 18, weight: .regular, design: .monospaced)
        static let monoSmall = Font.system(size: 14, weight: .regular, design: .monospaced)

        // Sidebar
        static let sidebarTitle = Font.system(size: 13, weight: .semibold, design: .rounded)
        static let sidebarItem = Font.system(size: 13, weight: .regular, design: .rounded)
    }

    // MARK: - Spacing (4pt grid)
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 40

        // Legacy aliases for compatibility
        static let quarter: CGFloat = 2
        static let half: CGFloat = 6
        static let oneAndHalf: CGFloat = 12
        static let twoAndHalf: CGFloat = 20
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let subtle: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let circle: CGFloat = 999
    }

    // MARK: - Line Widths
    struct LineWidth {
        static let hairline: CGFloat = 0.5
        static let thin: CGFloat = 1.0
        static let regular: CGFloat = 1.5
        static let medium: CGFloat = 2.0
        static let thick: CGFloat = 3.0
    }

    // MARK: - Animation
    struct Animation {
        static let instant = SwiftUI.Animation.easeOut(duration: 0.1)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let gentle = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let snappy = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.7)
    }

    // MARK: - Shadows
    struct Shadows {
        static let subtle = Color.black.opacity(0.3)
        static let medium = Color.black.opacity(0.5)
        static let strong = Color.black.opacity(0.7)
        static let glow = Color(hex: "#58A6FF").opacity(0.2)
    }

    // MARK: - Layout
    struct Layout {
        static let sidebarWidth: CGFloat = 220
        static let sidebarMinWidth: CGFloat = 180
        static let sidebarMaxWidth: CGFloat = 280
        static let windowMinWidth: CGFloat = 780
        static let windowMinHeight: CGFloat = 520
        static let contentMaxWidth: CGFloat = 680
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

/// Refined card style with subtle depth
struct CardModifier: ViewModifier {
    let elevated: Bool
    let accent: Bool

    init(elevated: Bool = false, accent: Bool = false) {
        self.elevated = elevated
        self.accent = accent
    }

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(elevated ? DesignSystem.Colors.surfaceHigh : DesignSystem.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        accent ? DesignSystem.Colors.accent.opacity(0.3) : DesignSystem.Colors.borderSubtle,
                        lineWidth: 1
                    )
            )
    }
}

/// Glass-morphism container for overlays
struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(DesignSystem.Colors.glassBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(.ultraThinMaterial)
            )
    }
}

/// Modern primary button style
struct PrimaryButtonStyle: ButtonStyle {
    let size: ButtonSize
    let fullWidth: Bool

    enum ButtonSize {
        case small, medium, large

        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.caption
            case .medium: return DesignSystem.Typography.subheadline
            case .large: return DesignSystem.Typography.callout
            }
        }

        var padding: (h: CGFloat, v: CGFloat) {
            switch self {
            case .small: return (12, 6)
            case .medium: return (16, 8)
            case .large: return (20, 10)
            }
        }
    }

    init(size: ButtonSize = .medium, fullWidth: Bool = false) {
        self.size = size
        self.fullWidth = fullWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, size.padding.h)
            .padding(.vertical, size.padding.v)
            .frame(minHeight: 36)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(configuration.isPressed ? DesignSystem.Colors.accentStrong : DesignSystem.Colors.accent)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(DesignSystem.Animation.instant, value: configuration.isPressed)
    }
}

/// Secondary / ghost button
struct SecondaryButtonStyle: ButtonStyle {
    let size: PrimaryButtonStyle.ButtonSize
    let fullWidth: Bool

    init(size: PrimaryButtonStyle.ButtonSize = .medium, fullWidth: Bool = false) {
        self.size = size
        self.fullWidth = fullWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .fontWeight(.medium)
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .padding(.horizontal, size.padding.h)
            .padding(.vertical, size.padding.v)
            .frame(minHeight: 36)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(configuration.isPressed ? DesignSystem.Colors.surfaceHighest : DesignSystem.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(DesignSystem.Animation.instant, value: configuration.isPressed)
    }
}

/// Destructive button
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.subheadline)
            .fontWeight(.medium)
            .foregroundColor(DesignSystem.Colors.error)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(minHeight: 36)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(configuration.isPressed ? DesignSystem.Colors.errorMuted : DesignSystem.Colors.errorMuted.opacity(0.6))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(DesignSystem.Animation.instant, value: configuration.isPressed)
    }
}

/// Icon button (circular, for play/pause etc.)
struct IconButtonStyle: ButtonStyle {
    let color: Color
    let size: CGFloat

    init(color: Color = DesignSystem.Colors.textSecondary, size: CGFloat = 36) {
        self.color = color
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.45, weight: .medium))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(configuration.isPressed ? DesignSystem.Colors.surfaceHighest : DesignSystem.Colors.surface)
            )
            .overlay(
                Circle()
                    .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(DesignSystem.Animation.instant, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(elevated: Bool = false, accent: Bool = false) -> some View {
        modifier(CardModifier(elevated: elevated, accent: accent))
    }

    func glassStyle() -> some View {
        modifier(GlassModifier())
    }

    func primaryButtonStyle(size: PrimaryButtonStyle.ButtonSize = .medium, fullWidth: Bool = false) -> some View {
        buttonStyle(PrimaryButtonStyle(size: size, fullWidth: fullWidth))
    }

    func secondaryButtonStyle(size: PrimaryButtonStyle.ButtonSize = .medium, fullWidth: Bool = false) -> some View {
        buttonStyle(SecondaryButtonStyle(size: size, fullWidth: fullWidth))
    }

    func destructiveButtonStyle() -> some View {
        buttonStyle(DestructiveButtonStyle())
    }

    func iconButtonStyle(color: Color = DesignSystem.Colors.textSecondary, size: CGFloat = 36) -> some View {
        buttonStyle(IconButtonStyle(color: color, size: size))
    }
}

// MARK: - Shared Components

/// Section header used across views
struct SectionHeader: View {
    let title: String
    let count: Int?
    let color: Color

    init(title: String, count: Int? = nil, color: Color = DesignSystem.Colors.accent) {
        self.title = title
        self.count = count
        self.color = color
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            if let count = count {
                Text("\(count)")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(DesignSystem.Colors.surfaceHigh)
                    )
            }

            Spacer()
        }
    }
}

/// Empty state placeholder
struct EmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .light))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            Text(message)
                .font(DesignSystem.Typography.footnote)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

/// Priority badge
struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.taskPriority(priority))
                .frame(width: 6, height: 6)
            Text(priority.displayName)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(Color.taskPriority(priority))
        }
    }
}

/// Clock icon
struct ClockIcon: View {
    let size: CGFloat
    let color: Color

    init(size: CGFloat = 16, color: Color = DesignSystem.Colors.textSecondary) {
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)

            Rectangle()
                .fill(color)
                .frame(width: 1.5, height: size * 0.3)
                .offset(y: -size * 0.15)

            Rectangle()
                .fill(color)
                .frame(width: 1.5, height: size * 0.2)
                .offset(x: size * 0.1, y: -size * 0.1)

            Circle()
                .fill(color)
                .frame(width: 3, height: 3)
        }
    }
}