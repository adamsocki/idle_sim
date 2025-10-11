//
//  MetricCard.swift
//  idle_01
//
//  Created by Adam Socki on 10/11/25.
//

import SwiftUI

/// A minimal, terminal-inspired metric display that embodies "fragments of memory."
///
/// This component reflects the game's core aesthetic: ephemeral, contemplative,
/// and quietly beautiful. Metrics are presented as fleeting consciousness fragments
/// from the city's collective awareness.
///
/// Usage:
/// ```swift
/// MetricCard(
///     label: "collective trust",
///     value: "73%",
///     icon: "心",
///     style: .consciousness
/// )
///
/// MetricCard(
///     label: "active thoughts",
///     value: "2,847",
///     icon: "◉",
///     style: .data
/// )
/// ```
struct MetricCard: View {
    // MARK: - Configuration

    let label: String
    let value: String
    let icon: String
    let style: Style

    // MARK: - State

    @State private var isHovering = false
    @State private var pulseAnimation = false

    // MARK: - Initializers

    /// Creates a metric card with terminal aesthetic
    /// - Parameters:
    ///   - label: Lowercase metric description (e.g., "coherence level")
    ///   - value: The metric value (e.g., "89%", "2.4k")
    ///   - icon: Simple unicode or SF Symbol glyph
    ///   - style: Visual variant that affects glow and emphasis
    init(
        label: String,
        value: String,
        icon: String,
        style: Style = .data
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.style = style
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon - more visible
            HStack {
                Text(icon)
                    .font(.system(size: 22, weight: .light, design: .monospaced))
                    .foregroundStyle(style.accentColor.opacity(isHovering ? 0.6 : 0.45))

                Spacer()
            }

            Spacer()

            // Value - clear and readable
            Text(value)
                .font(.system(size: 40, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.95))
                .monospacedDigit()
                .tracking(0.5)

            // Label - visible and clear
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.75))
                .tracking(1.0)
                .textCase(.lowercase)
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 150)
        .background(style.background(isHovering: isHovering))
        .overlay(
            Rectangle()
                .strokeBorder(style.borderColor(isHovering: isHovering), lineWidth: 1)
        )
        // Subtle glow on hover - the metric awakens to attention
        .shadow(
            color: style.accentColor.opacity(isHovering ? 0.3 : 0),
            radius: isHovering ? 24 : 0,
            x: 0,
            y: 0
        )
        .shadow(
            color: style.accentColor.opacity(isHovering ? 0.2 : 0),
            radius: isHovering ? 12 : 0,
            x: 0,
            y: 0
        )
        .contentShape(Rectangle())
        .opacity(style.shouldPulse ? (pulseAnimation ? 0.94 : 1.0) : 1.0)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.4)) {
                isHovering = hovering
            }
        }
        .onAppear {
            if style.shouldPulse {
                withAnimation(
                    .easeInOut(duration: 5.0)
                    .repeatForever(autoreverses: true)
                ) {
                    pulseAnimation = true
                }
            }
        }
    }
}

// MARK: - Metric Styles

extension MetricCard {
    enum Style {
        case data           // Standard metrics - muted teal
        case consciousness  // Awareness metrics - muted purple, pulses
        case warning        // Attention needed - muted amber
        case fragment       // Almost invisible
        case void           // Pure depth
        case gradient       // Subtle color wash
        case ink            // Like ink bleed on paper

        var accentColor: Color {
            switch self {
            case .data:
                return Color(red: 0.4, green: 0.6, blue: 0.6)  // Muted teal
            case .consciousness:
                return Color(red: 0.5, green: 0.4, blue: 0.6)  // Muted purple
            case .warning:
                return Color(red: 0.7, green: 0.5, blue: 0.3)  // Muted amber
            case .fragment:
                return .white
            case .void:
                return Color(red: 0.2, green: 0.2, blue: 0.25)
            case .gradient:
                return Color(red: 0.3, green: 0.5, blue: 0.7)
            case .ink:
                return Color(red: 0.25, green: 0.3, blue: 0.4)
            }
        }

        var shouldPulse: Bool {
            switch self {
            case .consciousness: return true
            default: return false
            }
        }

        func borderColor(isHovering: Bool) -> Color {
            switch self {
            case .data, .consciousness, .warning:
                return accentColor.opacity(isHovering ? 0.25 : 0.15)
            case .fragment:
                return .white.opacity(isHovering ? 0.15 : 0.08)
            case .void:
                return .white.opacity(isHovering ? 0.2 : 0.1)
            case .gradient, .ink:
                return accentColor.opacity(isHovering ? 0.3 : 0.18)
            }
        }

        @ViewBuilder
        func background(isHovering: Bool) -> some View {
            switch self {
            case .data, .consciousness, .warning:
                // Subtle color tint with visible border
                Rectangle()
                    .fill(accentColor.opacity(isHovering ? 0.12 : 0.08))

            case .fragment:
                // Almost invisible with subtle border
                Rectangle()
                    .fill(.white.opacity(isHovering ? 0.05 : 0.03))

            case .void:
                // Pure depth - darker recessed area with border
                Rectangle()
                    .fill(.black.opacity(isHovering ? 0.45 : 0.30))

            case .gradient:
                // Subtle gradient wash with border
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(isHovering ? 0.15 : 0.10),
                                accentColor.opacity(isHovering ? 0.08 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

            case .ink:
                // Ink bleed effect - radial fade from center with border
                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                accentColor.opacity(isHovering ? 0.18 : 0.12),
                                accentColor.opacity(isHovering ? 0.08 : 0.05),
                                accentColor.opacity(0.02)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview("Metric Fragments") {
    ZStack {
        // Deep atmospheric gradient - digital twilight
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.05, blue: 0.1),
                Color(red: 0.05, green: 0.08, blue: 0.15),
                Color(red: 0.08, green: 0.05, blue: 0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 40) {
                // Header - terminal aesthetic
                VStack(alignment: .leading, spacing: 8) {
                    Text("// metric fragments")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))

                    Text("the city whispers its state")
                        .font(.system(size: 9, weight: .light, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.25))
                        .italic()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Section 1: Standard metrics
                Text("standard metrics")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    MetricCard(
                        label: "active thoughts",
                        value: "2,847",
                        icon: "◉",
                        style: .data
                    )

                    MetricCard(
                        label: "cycles elapsed",
                        value: "14.2k",
                        icon: "⟳",
                        style: .data
                    )

                    MetricCard(
                        label: "energy flow",
                        value: "891 MW",
                        icon: "∿",
                        style: .data
                    )
                }
                .padding(.horizontal, 24)

                // Section 2: Consciousness (pulses gently)
                Text("consciousness metrics")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    MetricCard(
                        label: "collective trust",
                        value: "73%",
                        icon: "心",
                        style: .consciousness
                    )

                    MetricCard(
                        label: "coherence level",
                        value: "0.89",
                        icon: "∞",
                        style: .consciousness
                    )

                    MetricCard(
                        label: "autonomy index",
                        value: "42%",
                        icon: "◈",
                        style: .consciousness
                    )
                }
                .padding(.horizontal, 24)

                // Section 3: Experimental styles
                Text("experimental styles")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    MetricCard(
                        label: "attention needed",
                        value: "12h 34m",
                        icon: "△",
                        style: .warning
                    )

                    MetricCard(
                        label: "void state",
                        value: "null",
                        icon: "□",
                        style: .void
                    )

                    MetricCard(
                        label: "gradient wash",
                        value: "0.42",
                        icon: "≈",
                        style: .gradient
                    )

                    MetricCard(
                        label: "ink bleed",
                        value: "diffuse",
                        icon: "◌",
                        style: .ink
                    )

                    MetricCard(
                        label: "fragment",
                        value: "14m ago",
                        icon: "·",
                        style: .fragment
                    )
                }
                .padding(.horizontal, 24)

                // Design notes
                VStack(alignment: .leading, spacing: 16) {
                    Text("// design notes")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))

                    VStack(alignment: .leading, spacing: 10) {
                        designNote(
                            marker: "—",
                            text: "visible borders: subtle accent-colored borders (15-30% opacity)"
                        )

                        designNote(
                            marker: "—",
                            text: "muted colors: desaturated teal/purple/amber tints"
                        )

                        designNote(
                            marker: "—",
                            text: "larger text: 40pt value, 13pt label (highly readable)"
                        )

                        designNote(
                            marker: "—",
                            text: "text visibility: 95% value, 75% label, 45% icon"
                        )

                        designNote(
                            marker: "—",
                            text: "generous padding: 32px buffer keeps text away from edges"
                        )

                        designNote(
                            marker: "—",
                            text: "visible backgrounds: increased opacity for better contrast"
                        )

                        designNote(
                            marker: "—",
                            text: "consciousness pulses: 5s slow breathing"
                        )

                        designNote(
                            marker: "—",
                            text: "void: pure depth with darker recessed fill and border"
                        )

                        designNote(
                            marker: "—",
                            text: "gradient: subtle diagonal color wash with border"
                        )

                        designNote(
                            marker: "—",
                            text: "ink: radial fade like ink bleeding through paper"
                        )

                        designNote(
                            marker: "—",
                            text: "fragment: nearly invisible, but still has subtle border"
                        )
                    }
                }
                .padding(24)
                .background(.black.opacity(0.2))
                .overlay(
                    Rectangle()
                        .strokeBorder(.white.opacity(0.05), lineWidth: 0.5)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    .frame(width: 900, height: 800)
}

// MARK: - Preview Helpers

private func designNote(marker: String, text: String) -> some View {
    HStack(alignment: .top, spacing: 8) {
        Text(marker)
            .font(.system(size: 9, weight: .light, design: .monospaced))
            .foregroundStyle(.cyan.opacity(0.5))

        Text(text)
            .font(.system(size: 9, weight: .light, design: .monospaced))
            .foregroundStyle(.white.opacity(0.35))
    }
}
