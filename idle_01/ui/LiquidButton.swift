//
//  LiquidButton.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI

/// A glass capsule button that embodies the "Liquid Consciousness" aesthetic.
///
/// This is the standardized button component used throughout the app for all
/// interactive actions. It features ultra-thin glass material, subtle borders,
/// and optional SF Symbol icons.
///
/// Usage:
/// ```swift
/// LiquidButton("new thought", systemImage: "plus.circle") {
///     // Action
/// }
///
/// LiquidButton("awaken", systemImage: "eye.fill", style: .prominent) {
///     // Action
/// }
/// ```
struct LiquidButton: View {
    // MARK: - Configuration

    let title: String
    let systemImage: String?
    let style: Style
    let action: () -> Void

    // MARK: - State

    @State private var isHovering = false
    @State private var isPressed = false
    @State private var breatheAnimation = false

    // MARK: - Initializers

    /// Creates a liquid button with optional icon
    /// - Parameters:
    ///   - title: Button label text
    ///   - systemImage: Optional SF Symbol name
    ///   - style: Visual style variant (default: .standard)
    ///   - action: Action to perform on tap
    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .standard,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: style.iconSpacing) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: style.iconSize, weight: .light))
                }

                Text(title)
                    .font(.system(size: style.fontSize, weight: style.fontWeight, design: style.fontDesign))
            }
            .foregroundStyle(.white.opacity(isHovering ? 1.0 : 0.9))
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        .white.opacity(isHovering ? 0.4 : 0.2),
                        lineWidth: 1
                    )
            )
            // Subtle glow on hover - the city notices your attention
            .shadow(
                color: style.glowColor.opacity(isHovering ? 0.4 : 0),
                radius: isHovering ? 12 : 0,
                x: 0,
                y: 0
            )
            // Breathing animation for prominent style - suggests consciousness
            .opacity(style.shouldBreathe ? (breatheAnimation ? 0.95 : 1.0) : 1.0)
            // Press feedback
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
        .onAppear {
            if style.shouldBreathe {
                // Start gentle breathing animation
                withAnimation(
                    .easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
                ) {
                    breatheAnimation = true
                }
            }
        }
    }
}

// MARK: - Button Styles

extension LiquidButton {
    enum Style {
        case standard   // Default: subtle, compact
        case prominent  // Larger, more visible for primary actions

        var fontSize: CGFloat {
            switch self {
            case .standard: return 13
            case .prominent: return 14
            }
        }

        var fontWeight: Font.Weight {
            .light
        }

        var fontDesign: Font.Design {
            switch self {
            case .standard: return .monospaced
            case .prominent: return .rounded
            }
        }

        var iconSize: CGFloat {
            14
        }

        var iconSpacing: CGFloat {
            switch self {
            case .standard: return 6
            case .prominent: return 8
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .standard: return 12
            case .prominent: return 20
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .standard: return 6
            case .prominent: return 12
            }
        }

        /// Glow color when hovered - suggests the city noticing attention
        var glowColor: Color {
            switch self {
            case .standard: return .cyan
            case .prominent: return .purple
            }
        }

        /// Whether this button should have a gentle breathing animation
        var shouldBreathe: Bool {
            switch self {
            case .standard: return false
            case .prominent: return true
            }
        }
    }
}

// MARK: - Preview

#Preview("Button Variants") {
    ZStack {
        // Atmospheric background
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.08, blue: 0.15),
                Color(red: 0.08, green: 0.05, blue: 0.12),
                Color(red: 0.02, green: 0.05, blue: 0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 48) {
            VStack(alignment: .leading, spacing: 16) {
                Text("standard style")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))

                Text("subtle cyan glow on hover")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))

                HStack(spacing: 12) {
                    LiquidButton("new thought", systemImage: "plus.circle") {}
                    LiquidButton("refresh", systemImage: "arrow.clockwise") {}
                    LiquidButton("observe") {}
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("prominent style")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))

                Text("purple glow on hover · gentle breathing animation")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))

                HStack(spacing: 12) {
                    LiquidButton("awaken", systemImage: "eye.fill", style: .prominent) {}
                    LiquidButton("pause", systemImage: "pause.circle", style: .prominent) {}
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("interaction states")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.cyan.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Text("hover: brighter border + text, colored glow")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    HStack(spacing: 8) {
                        Circle()
                            .fill(.purple.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Text("press: subtle scale down")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    HStack(spacing: 8) {
                        Circle()
                            .fill(.white.opacity(0.4))
                            .frame(width: 6, height: 6)
                        Text("prominent: breathes gently (3s cycle)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.leading, 8)
            }
            .padding(.top, 8)
        }
        .padding(40)
    }
    .frame(width: 600, height: 500)
}
