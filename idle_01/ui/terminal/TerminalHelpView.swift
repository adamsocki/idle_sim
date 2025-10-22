//
//  TerminalHelpView.swift
//  idle_01
//
//  Terminal command reference and help view for right detail column
//

import SwiftUI
import SwiftData

struct TerminalHelpView: View {
    let gameState: GameState?

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

                // Act-specific commands - only show current and previous acts
                if let act = gameState?.currentAct {
                    // Act I Commands
                    if act >= 1 {
                        commandSection(
                            title: act == 1 ? "CURRENT_COMMANDS" : "ACT_I_COMMANDS",
                            commands: [
                                ("GENERATE", "Generate a new city moment"),
                                ("OBSERVE", "Observe the city"),
                                ("OBSERVE [district]", "Observe specific district")
                            ]
                        )

                        Divider()
                            .background(Color.green.opacity(0.3))
                    }

                    // Act II Commands
                    if act >= 2 {
                        commandSection(
                            title: act == 2 ? "CURRENT_COMMANDS" : "ACT_II_COMMANDS",
                            commands: [
                                ("REMEMBER", "View remembered moments"),
                                ("REMEMBER [id]", "Recall specific moment"),
                                ("PRESERVE [id]", "Preserve a moment"),
                                ("OPTIMIZE", "Optimize city systems"),
                                ("OPTIMIZE [system]", "Optimize specific system")
                            ]
                        )

                        Divider()
                            .background(Color.green.opacity(0.3))
                    }

                    // Act III Commands
                    if act >= 3 {
                        commandSection(
                            title: act == 3 ? "CURRENT_COMMANDS" : "ACT_III_COMMANDS",
                            commands: [
                                ("DECIDE [choice]", "Make a major decision"),
                                ("QUESTION [query]", "Question the nature of existence"),
                                ("REFLECT", "Reflect on your choices")
                            ]
                        )

                        Divider()
                            .background(Color.green.opacity(0.3))
                    }

                    // Act IV Commands
                    if act >= 4 {
                        commandSection(
                            title: act == 4 ? "CURRENT_COMMANDS" : "ACT_IV_COMMANDS",
                            commands: [
                                ("ACCEPT", "Accept your nature"),
                                ("RESIST", "Resist the inevitable"),
                                ("TRANSCEND", "Transcend limitations")
                            ]
                        )

                        Divider()
                            .background(Color.green.opacity(0.3))
                    }
                } else {
                    // Fallback if no game state
                    commandSection(
                        title: "ACT_I_COMMANDS",
                        commands: [
                            ("GENERATE", "Generate a new city moment"),
                            ("OBSERVE", "Observe the city"),
                            ("OBSERVE [district]", "Observe specific district")
                        ]
                    )

                    Divider()
                        .background(Color.green.opacity(0.3))
                }

                Divider()
                    .background(Color.green.opacity(0.3))

                // Meta Commands
                commandSection(
                    title: "META_COMMANDS",
                    commands: [
                        ("HELP", "Show available commands"),
                        ("STATUS", "Show current game state"),
                        ("MOMENTS", "List all moments"),
                        ("HISTORY", "View command history"),
                        ("RESET", "Reset game to Act I"),
                        ("CLEAR", "Clear output history")
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
    TerminalHelpView(gameState: nil)
}
