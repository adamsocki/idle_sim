//
//  TerminalDivider.swift
//  idle_01
//
//  Terminal-styled section divider with ASCII line art
//

import SwiftUI

struct TerminalDivider: View {
    var style: DividerStyle = .solid
    var label: String? = nil

    enum DividerStyle {
        case solid
        case dashed
        case dotted

        var character: String {
            switch self {
            case .solid: return "─"
            case .dashed: return "╌"
            case .dotted: return "┈"
            }
        }
    }

    var body: some View {
        if let label = label {
            // Divider with label
            HStack(spacing: 4) {
                dividerLine

                Text("// \(label.uppercased())")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.6))
                    .fixedSize()

                dividerLine
            }
            .frame(height: 20)
        } else {
            // Plain divider
            dividerLine
                .frame(height: 12)
        }
    }

    private var dividerLine: some View {
        GeometryReader { geometry in
            Text(String(repeating: style.character, count: Int(geometry.size.width / 7)))
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.3))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Content Above")
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(Color.green.opacity(0.8))

        TerminalDivider()

        Text("Content Below")
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(Color.green.opacity(0.8))

        TerminalDivider(style: .dashed)

        Text("Dashed Style")
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(Color.green.opacity(0.8))

        TerminalDivider(style: .dotted, label: "Display Settings")

        Text("With Label")
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(Color.green.opacity(0.8))

        TerminalDivider(label: "Simulation Settings")

        Text("Another Section")
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(Color.green.opacity(0.8))
    }
    .padding()
    .background(Color.black)
}
