//
//  TerminalInputView.swift
//  idle_01
//
//  Full-screen terminal input interface for left sidebar
//

import SwiftUI
import SwiftData

struct TerminalInputView: View {
    @Binding var commandText: String
    @Binding var terminalFontSize: CGFloat
    @Binding var commandHistory: [String]
    @Binding var outputHistory: [CommandOutput]

    @State private var historyIndex: Int = 0
    @State private var cursorBlink: Bool = false
    @State private var suggestions: [String] = []
    @FocusState private var isInputFocused: Bool

    let onExecute: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            outputLogView
            inputBarView
        }
        .background(Color.black)
        .onAppear {
            cursorBlink = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cursorBlink = true
            }
            isInputFocused = true
        }
        .onKeyPress(.upArrow) {
            navigateHistory(direction: .up)
            return .handled
        }
        .onKeyPress(.downArrow) {
            navigateHistory(direction: .down)
            return .handled
        }
        .background(
            Button("") { isInputFocused = true }
                .keyboardShortcut("l", modifiers: .command)
                .hidden()
        )
        .background(
            Button("") { increaseFontSize() }
                .keyboardShortcut("+", modifiers: .command)
                .hidden()
        )
        .background(
            Button("") { decreaseFontSize() }
                .keyboardShortcut("-", modifiers: .command)
                .hidden()
        )
    }

    // MARK: - Output Log

    private var outputLogView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    if outputHistory.isEmpty {
                        welcomeMessage
                    } else {
                        outputList
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: outputHistory.count) { _, _ in
                    if let last = outputHistory.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    private var welcomeMessage: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TERMINAL_READY")
                .font(terminalFont(12, weight: .bold))
                .foregroundStyle(Color.green.opacity(0.9))

            Text("Type 'help' for available commands")
                .font(terminalFont(10))
                .foregroundStyle(Color.green.opacity(0.5))
                .padding(.top, 2)
        }
        .padding(12)
    }

    private var outputList: some View {
        ForEach(outputHistory) { output in
            outputRow(output)
                .id(output.id)
        }
    }

    private func outputRow(_ output: CommandOutput) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(">>")
                .font(terminalFont(10))
                .foregroundStyle(Color.green.opacity(0.5))
                .fixedSize()

            Text(output.text)
                .font(terminalFont(10))
                .foregroundStyle(output.isError ? Color.orange.opacity(0.8) : Color.green.opacity(0.7))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 1)
    }

    // MARK: - Input Bar

    private var inputBarView: some View {
        VStack(spacing: 0) {
//            topBorder
            suggestionsView
            inputRow
//            bottomBorder
        }
        .background(Color.black)
    }

    private var topBorder: some View {
        Text("╔" + String(repeating: "═", count: 58) + "╗")
            .font(terminalFont(12))
            .foregroundStyle(Color.green.opacity(0.6))
            .lineLimit(1)
    }

    private var inputRow: some View {
        HStack(spacing: 4) {
            Text("║")
                .font(terminalFont(12))
                .foregroundStyle(Color.green.opacity(0.6))

            Text(">")
                .font(terminalFont(12, weight: .bold))
                .foregroundStyle(Color.green.opacity(0.9))

            ZStack(alignment: .leading) {
                inputField

                // Cursor positioned at the end of the text
                HStack(spacing: 0) {
                    Text(commandText)
                        .font(terminalFont(12))
                        .opacity(0) // Invisible text to measure width

                    cursorView
                }
            }

            Spacer()

            Text("║")
                .font(terminalFont(12))
                .foregroundStyle(Color.green.opacity(0.6))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.black)
    }

    private var inputField: some View {
        ZStack(alignment: .leading) {
            if commandText.isEmpty {
                Text("COMMAND_INPUT...")
                    .font(terminalFont(12))
                    .foregroundStyle(Color.green.opacity(0.3))
            }

            TextField("", text: $commandText)
                .textFieldStyle(.plain)
                .font(terminalFont(12))
                .foregroundStyle(Color.green.opacity(0.9))
                .focused($isInputFocused)
                .onSubmit {
                    executeCommand()
                }
                .onChange(of: commandText) { _, newValue in
                    updateSuggestions(for: newValue)
                }
        }
    }

    @ViewBuilder
    private var cursorView: some View {
        if isInputFocused {
            Text("█")
                .font(terminalFont(12))
                .foregroundStyle(Color.green)
                .opacity(cursorBlink ? 0.9 : 0.0)
                .fixedSize()
                .onAppear {
                    startCursorBlink()
                }
        }
    }

    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            cursorBlink.toggle()
        }
    }

    private var bottomBorder: some View {
        HStack(spacing: 0) {
            Text("╚")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.6))

            HStack(spacing: 0) {
                Text(String(repeating: "═", count: 30))
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.6))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            fontSizeControls

            HStack(spacing: 0) {
                Text(String(repeating: "═", count: 3))
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.6))
                    .lineLimit(1)
            }

            Text("╝")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.6))
        }
        .frame(height: 20)
    }

    private var fontSizeControls: some View {
        HStack(spacing: 2) {
            Button(action: { decreaseFontSize() }) {
                Text("[-]")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.7))
                    .frame(width: 28)
            }
            .buttonStyle(.plain)
            .help("Decrease font size (Cmd + -)")

            Text("SIZE:\(Int(terminalFontSize))")
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.5))
                .frame(width: 65)

            Button(action: { increaseFontSize() }) {
                Text("[+]")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.7))
                    .frame(width: 28)
            }
            .buttonStyle(.plain)
            .help("Increase font size (Cmd + +)")
        }
        .fixedSize()
    }

    @ViewBuilder
    private var suggestionsView: some View {
        if !suggestions.isEmpty && !commandText.isEmpty {
            HStack(spacing: 4) {
                Text("// SUGGESTIONS:")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.4))

                Text(suggestions.prefix(3).joined(separator: " | "))
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.5))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 12)
            .padding(.top, 2)
            .padding(.bottom, 4)
        }
    }

    // MARK: - Command Execution

    private func executeCommand() {
        let trimmed = commandText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        commandHistory.append(trimmed)
        historyIndex = commandHistory.count
        onExecute(trimmed)
        commandText = ""
        suggestions = []
    }

    // MARK: - History Navigation

    private func navigateHistory(direction: Direction) {
        guard !commandHistory.isEmpty else { return }

        switch direction {
        case .up:
            if historyIndex > 0 {
                historyIndex -= 1
                commandText = commandHistory[historyIndex]
            }
        case .down:
            if historyIndex < commandHistory.count - 1 {
                historyIndex += 1
                commandText = commandHistory[historyIndex]
            } else {
                historyIndex = commandHistory.count
                commandText = ""
            }
        }
    }

    enum Direction {
        case up, down
    }

    // MARK: - Autocomplete Suggestions

    private func updateSuggestions(for text: String) {
        if text.isEmpty {
            suggestions = []
            return
        }

        let technical: [String] = [
            "help", "list", "list --filter=active", "list --filter=dormant",
            "create city --name=NAME", "select [00]", "start [00]", "stop [00]",
            "delete [00]", "stats", "export --format=json", "clear"
        ]

        let poetic: [String] = [
            "awaken consciousness --name=NAME", "breathe life into [00]",
            "rest [00]", "forget [00]", "attend [00]"
        ]

        let all = technical + poetic
        suggestions = all.filter { $0.lowercased().contains(text.lowercased()) }
    }

    // MARK: - Font Size Controls

    private func increaseFontSize() {
        terminalFontSize = min(terminalFontSize + 1, 24)
    }

    private func decreaseFontSize() {
        terminalFontSize = max(terminalFontSize - 1, 8)
    }

    // MARK: - Helpers

    private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = terminalFontSize / 12.0
        return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
    }
}

#Preview {
    @Previewable @State var commandText: String = ""
    @Previewable @State var fontSize: CGFloat = 12
    @Previewable @State var history: [String] = []
    @Previewable @State var output: [CommandOutput] = []

    TerminalInputView(
        commandText: $commandText,
        terminalFontSize: $fontSize,
        commandHistory: $history,
        outputHistory: $output,
        onExecute: { _ in }
    )
    .frame(width: 400, height: 600)
}
