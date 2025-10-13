// //
// //  TerminalCommandBar.swift
// //  idle_01
// //
// //  Global terminal command input bar with history and autocomplete
// //

// import SwiftUI
// import SwiftData

// struct TerminalCommandBar: View {
//     // MARK: - Bindings (connected to parent view state)
//     @Binding var commandText: String
//     @Binding var terminalFontSize: CGFloat
//     @Binding var commandHistory: [String]
//     @Binding var outputHistory: [CommandOutput]

//     // MARK: - Internal State
//     @State private var historyIndex: Int = 0  // Current position in command history
//     @State private var cursorBlink: Bool = false  // Controls cursor animation
//     @State private var suggestions: [String] = []  // Autocomplete suggestions
//     @State private var terminalHeight: CGFloat = 120  // Resizable output log height
//     @State private var isDragging: Bool = false  // Divider drag state
//     @FocusState private var isInputFocused: Bool  // Input field focus state

//     // MARK: - Callback
//     let onExecute: (String) -> Void  // Called when user submits a command

//     // MARK: - Body
//     var body: some View {
//         VStack(spacing: 0) {
//             // MARK: Output Log Section
//             // Scrollable output history - displays last 8 command results
//             if !outputHistory.isEmpty {
//                 ScrollViewReader { proxy in
//                     ScrollView {
//                         VStack(alignment: .leading, spacing: 2) {
//                             ForEach(outputHistory.suffix(8)) { output in
//                                 outputRow(output)
//                                     .id(output.id)
//                             }
//                         }
//                         .padding(.horizontal, 8)
//                         .padding(.vertical, 6)
//                         // Auto-scroll to newest output
//                         .onChange(of: outputHistory.count) { _, _ in
//                             if let last = outputHistory.last {
//                                 withAnimation {
//                                     proxy.scrollTo(last.id, anchor: .bottom)
//                                 }
//                             }
//                         }
//                     }
//                 }
//                 .frame(height: terminalHeight)
//                 .background(Color.black)

//                 // MARK: Resizable Divider
//                 // Drag handle to resize output log (60-500px)
//                 Divider()
//                     .background(isDragging ? Color.accentColor : Color.secondary)
//                     .frame(height: 1)
//                     .overlay(
//                         // Invisible hit area for easier dragging
//                         Rectangle()
//                             .fill(Color.clear)
//                             .frame(height: 8)
//                             .contentShape(Rectangle())
//                     )
//                     .gesture(
//                         DragGesture()
//                             .onChanged { value in
//                                 isDragging = true
//                                 let newHeight = terminalHeight + value.translation.height
//                                 terminalHeight = min(max(newHeight, 60), 500)
//                             }
//                             .onEnded { _ in
//                                 isDragging = false
//                             }
//                     )
//                     .onHover { hovering in
//                         // Show resize cursor on hover
//                         if hovering {
//                             NSCursor.resizeUpDown.push()
//                         } else {
//                             NSCursor.pop()
//                         }
//                     }
//             }

//             // MARK: Command Input Section
//             // Terminal-style input bar with ASCII box-drawing borders
//             VStack(spacing: 0) {
// //                HStack{
// //                    // ASCII top border (╔═══╗)
// //                    Text(String(repeating: "═", count: 80))
// //                        .font(terminalFont(9))
// //                        .foregroundStyle(Color.green.opacity(0.6))
// //                        .lineLimit(1)
// //                    Spacer()
// //                }
                
//                 // MARK: Input Row
//                 // ║ > [text input] █ ║
//                 HStack(spacing: 4) {
//                     // Left border
//                     Text("║")
//                         .font(terminalFont(9))
//                         .foregroundStyle(Color.green.opacity(0.6))

//                     // Prompt character
//                     Text(">")
//                         .font(terminalFont(9, weight: .bold))
//                         .foregroundStyle(Color.green.opacity(0.9))

//                     // Text input field with custom placeholder
//                     ZStack(alignment: .leading) {
//                         if commandText.isEmpty {
//                             Text("COMMAND_INPUT...")
//                                 .font(terminalFont(9))
//                                 .foregroundStyle(Color.green.opacity(0.3))
//                         }

//                         TextField("", text: $commandText)
//                             .textFieldStyle(.plain)
//                             .font(terminalFont(9))
//                             .foregroundStyle(Color.green.opacity(0.9))
//                             .focused($isInputFocused)
//                             .onSubmit {
//                                 executeCommand()
//                             }
//                             .onChange(of: commandText) { _, newValue in
//                                 updateSuggestions(for: newValue)
//                             }
//                     }

//                     // Animated blinking cursor (only when focused)
//                     if isInputFocused {
//                         Text("█")
//                             .font(terminalFont(9))
//                             .foregroundStyle(Color.green.opacity(cursorBlink ? 0.9 : 0.2))
//                     }

//                     Spacer()

//                     // Right border
//                     Text("║")
//                         .font(terminalFont(9))
//                         .foregroundStyle(Color.green.opacity(0.6))
//                 }
//                 .padding(.vertical, 6)
//                 .padding(.horizontal, 8)
//                 .background(Color.black)

//                 // MARK: Bottom Border with Font Controls
//                 // ╚═══[font controls]═══╝
//                 HStack(spacing: 0) {
// //                    Text("╚")
// //                        .font(terminalFont(9))
// //                        .foregroundStyle(Color.green.opacity(0.6))
// //
// //                    Text(String(repeating: "═", count: 65))
// //                        .font(terminalFont(9))
// //                        .foregroundStyle(Color.green.opacity(0.6))
// //                        .lineLimit(1)

//                     // Embedded font size controls
//                     HStack(spacing: 4) {
//                         Button(action: { decreaseFontSize() }) {
//                             Text("[-]")
//                                 .font(terminalFont(8))
//                                 .foregroundStyle(Color.green.opacity(0.7))
//                         }
//                         .buttonStyle(.plain)
//                         .help("Decrease font size (Cmd + -)")

//                         Text("SIZE:\(Int(terminalFontSize))")
//                             .font(terminalFont(7))
//                             .foregroundStyle(Color.green.opacity(0.5))
//                             .frame(minWidth: 50)

//                         Button(action: { increaseFontSize() }) {
//                             Text("[+]")
//                                 .font(terminalFont(8))
//                                 .foregroundStyle(Color.green.opacity(0.7))
//                         }
//                         .buttonStyle(.plain)
//                         .help("Increase font size (Cmd + +)")
//                     }
//                     .padding(.leading, 12)
//                     Spacer()

// //                    Text(String(repeating: "═", count: 3))
// //                        .font(terminalFont(9))
// //                        .foregroundStyle(Color.green.opacity(0.6))
// //                        .lineLimit(1)
// //
// //                    Text("╝")
// //                        .font(terminalFont(9))
// //                        .foregroundStyle(Color.green.opacity(0.6))
//                 }
//                 .lineLimit(1)

//                 // MARK: Autocomplete Suggestions
//                 // Shows up to 3 matching commands below input
//                 HStack {
//                     if !suggestions.isEmpty && !commandText.isEmpty {
//                         HStack(spacing: 4) {
//                             Text("// SUGGESTIONS:")
//                                 .font(terminalFont(7))
//                                 .foregroundStyle(Color.green.opacity(0.4))

//                             Text(suggestions.prefix(3).joined(separator: " | "))
//                                 .font(terminalFont(7))
//                                 .foregroundStyle(Color.green.opacity(0.5))
//                         }
//                         .padding(.horizontal, 12)
//                         .padding(.top, 2)
//                     }
//                     Spacer()
//                 }
                
//             }
//             .background(Color.black)
//         }
//         // MARK: View Lifecycle & Keyboard Shortcuts
//         .onAppear {
//             // Start cursor blink animation loop
//             withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
//                 cursorBlink = true
//             }
//             // Auto-focus input on appear
//             isInputFocused = true
//         }
//         // Up/Down arrows for command history navigation
//         .onKeyPress(.upArrow) {
//             navigateHistory(direction: .up)
//             return .handled
//         }
//         .onKeyPress(.downArrow) {
//             navigateHistory(direction: .down)
//             return .handled
//         }
//         // Cmd+L: Focus input field
//         .background(
//             Button("") {
//                 isInputFocused = true
//             }
//             .keyboardShortcut("l", modifiers: .command)
//             .hidden()
//         )
//         // Cmd+Plus: Increase font size
//         .background(
//             Button("") {
//                 increaseFontSize()
//             }
//             .keyboardShortcut("+", modifiers: .command)
//             .hidden()
//         )
//         // Cmd+Minus: Decrease font size
//         .background(
//             Button("") {
//                 decreaseFontSize()
//             }
//             .keyboardShortcut("-", modifiers: .command)
//             .hidden()
//         )
//     }

//     // MARK: - Sub-Views

//     /// Renders a single output line with >> prefix
//     /// Shows errors in orange, normal output in green
//     private func outputRow(_ output: CommandOutput) -> some View {
//         HStack(alignment: .top, spacing: 4) {
//             Text(">>")
//                 .font(terminalFont(8))
//                 .foregroundStyle(Color.green.opacity(0.5))

//             Text(output.text)
//                 .font(terminalFont(8))
//                 .foregroundStyle(output.isError ? Color.orange.opacity(0.8) : Color.green.opacity(0.7))
//                 .frame(maxWidth: .infinity, alignment: .leading)
//         }
//     }

//     // MARK: - Command Execution

//     /// Executes the current command text
//     /// 1. Adds to history
//     /// 2. Calls onExecute callback
//     /// 3. Clears input and suggestions
//     private func executeCommand() {
//         let trimmed = commandText.trimmingCharacters(in: .whitespaces)
//         guard !trimmed.isEmpty else { return }

//         // Add to history
//         commandHistory.append(trimmed)
//         historyIndex = commandHistory.count

//         // Execute via callback
//         onExecute(trimmed)

//         // Clear input
//         commandText = ""
//         suggestions = []
//     }

//     // MARK: - History Navigation

//     /// Navigates through command history with up/down arrows
//     /// Up: Go to older commands
//     /// Down: Go to newer commands (or clear if at end)
//     private func navigateHistory(direction: Direction) {
//         guard !commandHistory.isEmpty else { return }

//         switch direction {
//         case .up:
//             if historyIndex > 0 {
//                 historyIndex -= 1
//                 commandText = commandHistory[historyIndex]
//             }
//         case .down:
//             if historyIndex < commandHistory.count - 1 {
//                 historyIndex += 1
//                 commandText = commandHistory[historyIndex]
//             } else {
//                 historyIndex = commandHistory.count
//                 commandText = ""
//             }
//         }
//     }

//     enum Direction {
//         case up, down
//     }

//     // MARK: - Autocomplete Suggestions

//     /// Filters available commands based on input text
//     /// Shows matching commands as suggestions below input
//     private func updateSuggestions(for text: String) {
//         if text.isEmpty {
//             suggestions = []
//             return
//         }

//         // Available commands (both technical and poetic)
//         // Split into separate arrays to help compiler type-checking
//         let technicalCommands: [String] = [
//             "help",
//             "list",
//             "list --filter=active",
//             "list --filter=dormant",
//             "create city --name=NAME",
//             "select [00]",
//             "start [00]",
//             "stop [00]",
//             "delete [00]",
//             "stats",
//             "export --format=json",
//             "clear"
//         ]

//         let poeticCommands: [String] = [
//             "awaken consciousness --name=NAME",
//             "breathe life into [00]",
//             "rest [00]",
//             "forget [00]",
//             "attend [00]"
//         ]

//         let allCommands = technicalCommands + poeticCommands

//         // Case-insensitive substring matching
//         suggestions = allCommands.filter { $0.lowercased().contains(text.lowercased()) }
//     }

//     // MARK: - Font Size Controls

//     /// Increases terminal font size (max: 20)
//     private func increaseFontSize() {
//         withAnimation(.easeInOut(duration: 0.2)) {
//             terminalFontSize = min(terminalFontSize + 1, 20)
//         }
//     }

//     /// Decreases terminal font size (min: 6)
//     private func decreaseFontSize() {
//         withAnimation(.easeInOut(duration: 0.2)) {
//             terminalFontSize = max(terminalFontSize - 1, 6)
//         }
//     }

//     // MARK: - Helpers

//     /// Creates a monospaced font scaled by terminalFontSize
//     /// Base size 9 is scaled proportionally
//     private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
//         let scaleFactor = terminalFontSize / 9.0
//         return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
//     }
// }

// #Preview {
//     @Previewable @State var commandText = ""
//     @Previewable @State var fontSize: CGFloat = 9
//     @Previewable @State var history = ["help", "list", "create city --name=TestCity"]
//     @Previewable @State var output = [
//         CommandOutput(text: "SYSTEM INITIALIZED", isError: false),
//         CommandOutput(text: "3 cities found", isError: false),
//         CommandOutput(text: "ERROR: Invalid command syntax", isError: true),
//         CommandOutput(text: "City 'TestCity' created successfully", isError: false)
//     ]

//     return TerminalCommandBar(
//         commandText: $commandText,
//         terminalFontSize: $fontSize,
//         commandHistory: $history,
//         outputHistory: $output,
//         onExecute: { command in
//             print("Executed: \(command)")
//         }
//     )
//     .frame(width: 800)
// }
