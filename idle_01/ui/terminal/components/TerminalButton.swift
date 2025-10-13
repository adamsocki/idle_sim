//
//  TerminalButton.swift
//  idle_01
//
//  Terminal-styled action button with ASCII brackets
//

import SwiftUI

struct TerminalButton: View {
    let label: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var width: CGFloat? = nil

    enum ButtonStyle {
        case primary
        case secondary
        case danger

        var textColor: Color {
            switch self {
            case .primary: return Color.green.opacity(0.9)
            case .secondary: return Color.green.opacity(0.7)
            case .danger: return Color.orange.opacity(0.8)
            }
        }

        var backgroundColor: Color {
            switch self {
            case .primary: return Color.green.opacity(0.08)
            case .secondary: return Color.green.opacity(0.04)
            case .danger: return Color.orange.opacity(0.08)
            }
        }

        var borderColor: Color {
            switch self {
            case .primary: return Color.green.opacity(0.6)
            case .secondary: return Color.green.opacity(0.4)
            case .danger: return Color.orange.opacity(0.6)
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("[")
                    .foregroundStyle(style.borderColor)

                Text(label.uppercased())
                    .foregroundStyle(style.textColor)
                    .frame(maxWidth: .infinity)

                Text("]")
                    .foregroundStyle(style.borderColor)
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(style.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(width: width)
        .help(label)
    }
}

#Preview {
    VStack(spacing: 12) {
        TerminalButton(label: "Execute Command", action: {})
        TerminalButton(label: "Reset Settings", action: {}, style: .secondary)
        TerminalButton(label: "Delete All", action: {}, style: .danger)

        HStack(spacing: 12) {
            TerminalButton(label: "Save", action: {}, width: 120)
            TerminalButton(label: "Cancel", action: {}, style: .secondary, width: 120)
        }
    }
    .padding()
    .background(Color.black)
}
