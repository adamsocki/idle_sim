//
//  TerminalHelpView.swift
//  idle_01
//
//  Terminal command reference and help view for right detail column
//

import SwiftUI

struct TerminalHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("TERMINAL_COMMANDS")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.green.opacity(0.9))

                    Text("// Quick Reference")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.green.opacity(0.5))
                }
                .padding(.bottom, 8)

                Divider()
                    .background(Color.green.opacity(0.3))

                // City Management
                commandSection(
                    title: "CITY_MANAGEMENT",
                    commands: [
                        ("create city --name=NAME", "Create new city"),
                        ("awaken consciousness", "Poetic: create city"),
                        ("list", "List all cities"),
                        ("list --filter=active", "List active cities"),
                        ("select [00]", "Select city by index"),
                        ("start [00]", "Start city simulation"),
                        ("stop [00]", "Stop city simulation"),
                        ("delete [00]", "Delete city")
                    ]
                )

                Divider()
                    .background(Color.green.opacity(0.3))

                // Information
                commandSection(
                    title: "INFORMATION",
                    commands: [
                        ("help", "Show all commands"),
                        ("stats", "Global statistics"),
                        ("stats [00]", "City-specific stats"),
                        ("clear", "Clear output history")
                    ]
                )

                Divider()
                    .background(Color.green.opacity(0.3))

                // Keyboard Shortcuts
                VStack(alignment: .leading, spacing: 8) {
                    Text("KEYBOARD_SHORTCUTS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.green.opacity(0.8))

                    shortcutRow("↑/↓", "Navigate history")
                    shortcutRow("Cmd+L", "Focus input")
                    shortcutRow("Cmd++", "Increase font")
                    shortcutRow("Cmd+-", "Decrease font")
                    shortcutRow("Cmd+Shift+T", "Toggle terminal")
                }

                Divider()
                    .background(Color.green.opacity(0.3))

                // Poetic Alternatives
                VStack(alignment: .leading, spacing: 8) {
                    Text("POETIC_SYNTAX")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.green.opacity(0.8))

                    Text("// Alternative command expressions")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(Color.green.opacity(0.4))
                        .padding(.bottom, 4)

                    poeticRow("awaken consciousness", "create city")
                    poeticRow("breathe life into", "start")
                    poeticRow("rest", "stop")
                    poeticRow("forget", "delete")
                    poeticRow("attend", "select")
                }

                Spacer()

                // Footer
                VStack(alignment: .leading, spacing: 2) {
                    Text("// █")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.green.opacity(0.3))
                }
            }
            .padding(16)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Sub-Views

    private func commandSection(title: String, commands: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.8))

            ForEach(commands, id: \.0) { command, description in
                commandRow(command: command, description: description)
            }
        }
    }

    private func commandRow(command: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(command)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.9))

            Text("// \(description)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.5))
        }
    }

    private func shortcutRow(_ key: String, _ description: String) -> some View {
        HStack(spacing: 8) {
            Text(key)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.9))
                .frame(width: 80, alignment: .leading)

            Text("// \(description)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.5))
        }
    }

    private func poeticRow(_ poetic: String, _ technical: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(poetic)
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("→")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.4))

            Text(technical)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.5))
        }
    }
}

#Preview {
    TerminalHelpView()
}
