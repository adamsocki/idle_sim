//
//  TerminalBox.swift
//  idle_01
//
//  Terminal-styled container with ASCII borders and optional title
//

import SwiftUI

struct TerminalBox<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top border with optional title
            if let title = title {
                HStack(spacing: 4) {
                    Text("┌─")
                        .foregroundStyle(Color.green.opacity(0.5))

                    Text("[ \(title.uppercased()) ]")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.green.opacity(0.8))

                    GeometryReader { geometry in
                        Text(String(repeating: "─", count: Int(geometry.size.width / 7)))
                            .lineLimit(1)
                            .foregroundStyle(Color.green.opacity(0.5))
                    }

                    Text("┐")
                        .foregroundStyle(Color.green.opacity(0.5))
                }
                .font(.system(size: 12, design: .monospaced))
            } else {
                HStack(spacing: 0) {
                    Text("┌")
                        .foregroundStyle(Color.green.opacity(0.5))

                    GeometryReader { geometry in
                        Text(String(repeating: "─", count: Int(geometry.size.width / 7)))
                            .lineLimit(1)
                            .foregroundStyle(Color.green.opacity(0.5))
                    }

                    Text("┐")
                        .foregroundStyle(Color.green.opacity(0.5))
                }
                .font(.system(size: 12, design: .monospaced))
                .frame(height: 16)
            }

            // Content area
            HStack(alignment: .top, spacing: 0) {
                Text("│")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.5))

                VStack(alignment: .leading, spacing: 0) {
                    content
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("│")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.5))
            }

            // Bottom border
            HStack(spacing: 0) {
                Text("└")
                    .foregroundStyle(Color.green.opacity(0.5))

                GeometryReader { geometry in
                    Text(String(repeating: "─", count: Int(geometry.size.width / 7)))
                        .lineLimit(1)
                        .foregroundStyle(Color.green.opacity(0.5))
                }

                Text("┘")
                    .foregroundStyle(Color.green.opacity(0.5))
            }
            .font(.system(size: 12, design: .monospaced))
            .frame(height: 16)
        }
        .background(Color.green.opacity(0.02))
    }
}

#Preview {
    VStack(spacing: 16) {
        TerminalBox(title: "Display Settings") {
            VStack(alignment: .leading, spacing: 12) {
                Text("CRT_EFFECT: ON")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.8))

                Text("FONT_SIZE: 12pt")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.8))

                Text("THEME: Matrix")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.8))
            }
        }

        TerminalBox {
            Text("This is a box without a title")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.8))
        }
    }
    .padding()
    .background(Color.black)
}
