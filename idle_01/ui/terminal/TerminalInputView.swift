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
    @Binding var terminalFontSize: Double
    @Binding var commandHistory: [String]
    @Binding var outputHistory: [CommandOutput]

    @State private var historyIndex: Int = 0
    @State private var cursorBlink: Bool = false
    @State private var suggestions: [String] = []
    @State private var crtFlicker: Double = 1.0
    @State private var suggestionIndex: Int = 0
    @FocusState private var isInputFocused: Bool

    // Settings from @AppStorage
    @AppStorage("terminal.crtEffect") private var crtEffectEnabled: Bool = true
    @AppStorage("terminal.cursorBlink") private var cursorBlinkEnabled: Bool = true
    @AppStorage("terminal.lineSpacing") private var lineSpacing: Double = 1.2

    // Optional context for placeholder text
    let selectedCityName: String?
    let onExecute: (String) -> Void

    init(
        commandText: Binding<String>,
        terminalFontSize: Binding<Double>,
        commandHistory: Binding<[String]>,
        outputHistory: Binding<[CommandOutput]>,
        selectedCityName: String? = nil,
        onExecute: @escaping (String) -> Void
    ) {
        self._commandText = commandText
        self._terminalFontSize = terminalFontSize
        self._commandHistory = commandHistory
        self._outputHistory = outputHistory
        self.selectedCityName = selectedCityName
        self.onExecute = onExecute
    }

    var body: some View {
        VStack(spacing: 0) {
            outputLogView
            inputBarView
        }
        .background(Color.black)
        .opacity(crtEffectEnabled ? crtFlicker : 1.0)
        .onAppear {
            cursorBlink = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cursorBlink = true
            }
            isInputFocused = true
            startCRTFlicker()
        }
        .onKeyPress(.upArrow) {
            navigateHistory(direction: .up)
            return .handled
        }
        .onKeyPress(.downArrow) {
            navigateHistory(direction: .down)
            return .handled
        }
        .onKeyPress(.tab) {
            handleTabCompletion()
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
                LazyVStack(alignment: .leading, spacing: 2) {
                    if outputHistory.isEmpty {
//                        welcomeMessage
                    } else {
                        outputList
                    }

                    // Bottom spacer to ensure last item can scroll into view
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: outputHistory.count) { _, _ in
                    // Scroll to bottom marker after layout completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
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
            // Different prefix for dialogue
            if output.isDialogue {
                Text("│")
                    .font(terminalFont(10))
                    .foregroundStyle(Color.cyan.opacity(0.6))
                    .fixedSize()
            } else {
                Text(">>")
                    .font(terminalFont(10))
                    .foregroundStyle(Color.green.opacity(0.5))
                    .fixedSize()
            }

            Text(output.text)
                .font(terminalFont(10))
                .foregroundStyle(
                    output.isDialogue ? Color.cyan.opacity(0.85) :  // Dialogue in cyan
                    output.isError ? Color.orange.opacity(0.8) :     // Errors in orange
                    Color.green.opacity(0.7)                          // Normal in green
                )
                .lineSpacing(lineSpacing)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, CGFloat(lineSpacing))
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
                Text(placeholderText)
                    .font(terminalFont(12))
                    .foregroundStyle(Color.green.opacity(0.3))
            }

            // Syntax-highlighted overlay (visual feedback)
            if !commandText.isEmpty {
                Text(syntaxHighlightedText)
                    .font(terminalFont(12))
                    .allowsHitTesting(false)
            }

            TextField("", text: $commandText)
                .textFieldStyle(.plain)
                .font(terminalFont(12))
                .foregroundStyle(Color.clear) // Make actual text transparent so highlighted version shows
                .focused($isInputFocused)
                .onSubmit {
                    executeCommand()
                }
                .onChange(of: commandText) { _, newValue in
                    updateSuggestions(for: newValue)
                }
        }
    }

    // Context-aware placeholder text
    private var placeholderText: String {
        if let cityName = selectedCityName {
            return "ATTENDING: \(cityName.uppercased()) | Type 'items' or 'create thought'..."
        } else {
            return "COMMAND_INPUT | Type 'help' or 'list'..."
        }
    }

    // Syntax highlighting for command text
    private var syntaxHighlightedText: AttributedString {
        var result = AttributedString(commandText)

        let components = commandText.split(separator: " ", omittingEmptySubsequences: false).map { String($0) }
        guard let firstWord = components.first?.lowercased() else { return result }

        // Command verbs (primary commands)
        let commandVerbs = ["help", "list", "create", "select", "start", "stop", "delete", "stats", "export", "clear", "items", "respond", "dismiss", "set", "awaken", "breathe", "rest", "forget", "attend", "answer", "acknowledge", "thoughts", "generate", "observe", "remember", "preserve", "optimize", "decide", "question", "reflect", "accept", "resist", "transcend", "status", "moments", "history"]

        // Aliases
        let aliases = ["ls", "ll", "la", "cc", "ct", "new", "sel", "cd", "run", "pause", "rm", "del", "i", "t", "r", "d", "s", "st", "cls", "clr", "?", "h"]

        var currentIndex = result.startIndex

        for (index, component) in components.enumerated() {
            let componentLower = component.lowercased()
            let range = findRange(of: component, in: result, startingFrom: currentIndex)

            guard let range = range else { continue }

            if index == 0 {
                // First word: command verb or alias
                if commandVerbs.contains(componentLower) {
                    result[range].foregroundColor = .green.opacity(0.95) // Bright green for commands
                } else if aliases.contains(componentLower) {
                    result[range].foregroundColor = .cyan.opacity(0.9) // Cyan for aliases
                } else {
                    result[range].foregroundColor = .orange.opacity(0.8) // Orange for unknown
                }
            } else if component.hasPrefix("--") {
                // Flags
                result[range].foregroundColor = .yellow.opacity(0.85)
            } else if component.hasPrefix("[") && component.hasSuffix("]") {
                // Indices like [00]
                result[range].foregroundColor = .blue.opacity(0.9)
            } else if component.hasPrefix("\"") || component.hasSuffix("\"") {
                // String literals
                result[range].foregroundColor = .green.opacity(0.6)
            } else if Int(component) != nil || Double(component) != nil {
                // Numbers
                result[range].foregroundColor = .purple.opacity(0.85)
            } else {
                // Arguments
                result[range].foregroundColor = .green.opacity(0.7)
            }

            currentIndex = range.upperBound
        }

        return result
    }

    // Helper to find range of substring
    private func findRange(of substring: String, in attributedString: AttributedString, startingFrom: AttributedString.Index) -> Range<AttributedString.Index>? {
        let remainingString = String(attributedString[startingFrom...].characters)
        guard let range = remainingString.range(of: substring) else { return nil }

        let startOffset = remainingString.distance(from: remainingString.startIndex, to: range.lowerBound)
        let endOffset = startOffset + substring.count

        var currentIndex = startingFrom
        for _ in 0..<startOffset {
            currentIndex = attributedString.index(afterCharacter: currentIndex)
        }

        var endIndex = currentIndex
        for _ in 0..<substring.count {
            endIndex = attributedString.index(afterCharacter: endIndex)
        }

        return currentIndex..<endIndex
    }

    @ViewBuilder
    private var cursorView: some View {
        if isInputFocused {
            Text("█")
                .font(terminalFont(12))
                .foregroundStyle(Color.green)
                .opacity(cursorBlinkEnabled ? (cursorBlink ? 0.9 : 0.0) : 0.9)
                .fixedSize()
                .onAppear {
                    if cursorBlinkEnabled {
                        startCursorBlink()
                    }
                }
        }
    }

    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if cursorBlinkEnabled {
                cursorBlink.toggle()
            }
        }
    }

    private func startCRTFlicker() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if crtEffectEnabled {
                // Random subtle flicker between 0.95 and 1.0
                crtFlicker = Double.random(in: 0.8...1.0)
            } else {
                crtFlicker = 1.0
            }
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

    // MARK: - Tab Completion

    private func handleTabCompletion() {
        guard !commandText.isEmpty, !suggestions.isEmpty else { return }

        // Cycle through suggestions with repeated tab presses
        commandText = suggestions[suggestionIndex % suggestions.count]
        suggestionIndex = (suggestionIndex + 1) % suggestions.count
    }

    // MARK: - Autocomplete Suggestions

    private func updateSuggestions(for text: String) {
        // Reset suggestion index when text changes
        suggestionIndex = 0

        if text.isEmpty {
            suggestions = []
            return
        }

        let technical: [String] = [
            "help", "list", "list --filter=active", "list --filter=dormant",
            "create city --name=NAME", "select [00]", "start [00]", "stop [00]",
            "delete [00]", "stats", "export --format=json", "clear",
            "create thought", "create thought --type=memory", "create thought --type=request",
            "create thought --type=dream", "create thought --type=warning",
            "items", "items [00]", "items --filter=memory", "items --filter=request",
            "items --filter=pending", "respond [00] \"text\"", "dismiss [00]"
        ]

        let poetic: [String] = [
            "awaken consciousness --name=NAME", "breathe life into [00]",
            "rest [00]", "forget [00]", "attend [00]",
            "answer [00] \"text\"", "acknowledge [00]", "thoughts"
        ]

        let settings: [String] = [
            "set crt on", "set crt off", "set font 12", "set cursor on", "set cursor off",
            "set linespacing 1.2", "set coherence 75", "set trust 0.85",
            "set autosave on", "set autosave off", "set interval 1000",
            "set verbose on", "set verbose off", "set stats on", "set stats off",
            "set performance on", "set performance off"
        ]

        let all = technical + poetic + settings
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
    @Previewable @State var fontSize: Double = 12
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
