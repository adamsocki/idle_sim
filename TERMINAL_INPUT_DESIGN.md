# Terminal Input Interface - Design Document

> *"Type to control. Command the consciousness."*

---

## The Question

**Where should a terminal text input go, and what should it control?**

This explores multiple approaches for integrating a command-line interface into the terminal UI, allowing keyboard-driven control as an alternative (or complement) to mouse interaction.

---

## Approach 1: Global Bottom Bar (Recommended)

### Concept
A persistent command input bar at the very bottom of the window, available from any view. Think vim status line, tmux command prompt, or macOS Terminal itself.

### Visual

```
┌──────────────┬───────────────────┬──────────────┐
│              │                   │              │
│ LEFT         │ CENTER            │ RIGHT        │
│ (content)    │ (content)         │ (content)    │
│              │                   │              │
│              │                   │              │
│              │                   │              │
└──────────────┴───────────────────┴──────────────┘
╔══════════════════════════════════════════════════╗
║ > create city --name=ALPHA_________________________║
╚══════════════════════════════════════════════════╝
  ^cursor here
```

### Implementation

**File:** `idle_01/ui/terminal/TerminalCommandBar.swift`

```swift
import SwiftUI

struct TerminalCommandBar: View {
    @Binding var commandText: String
    @Binding var terminalFontSize: CGFloat
    @Binding var commandHistory: [String]

    @State private var historyIndex: Int = 0
    @State private var isFocused: Bool = false
    @FocusState private var textFieldFocused: Bool

    let onExecute: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Text("╔" + String(repeating: "═", count: 80) + "╗")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))
                .lineLimit(1)

            // Input row
            HStack(spacing: 4) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text(">")
                    .font(terminalFont(9, weight: .bold))
                    .foregroundStyle(Color.green.opacity(0.9))

                // Text input
                TextField("", text: $commandText)
                    .textFieldStyle(.plain)
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.9))
                    .focused($textFieldFocused)
                    .onSubmit {
                        executeCommand()
                    }
                    .overlay(
                        // Blinking cursor effect when focused
                        HStack {
                            Spacer()
                            if textFieldFocused {
                                Text("█")
                                    .font(terminalFont(9))
                                    .foregroundStyle(Color.green.opacity(0.8))
                                    .opacity(isFocused ? 1.0 : 0.0)
                                    .padding(.trailing, 4)
                            }
                        }
                    )

                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.black)

            // Bottom border
            Text("╚" + String(repeating: "═", count: 80) + "╝")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))
                .lineLimit(1)
        }
        .background(Color.black)
        .onAppear {
            // Start cursor blink
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                isFocused = true
            }
        }
        // Keyboard shortcuts for history navigation
        .onKeyPress(.upArrow) {
            navigateHistory(direction: .up)
            return .handled
        }
        .onKeyPress(.downArrow) {
            navigateHistory(direction: .down)
            return .handled
        }
    }

    // MARK: - Helpers

    private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = terminalFontSize / 9.0
        return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
    }

    private func executeCommand() {
        let trimmed = commandText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Add to history
        commandHistory.append(trimmed)
        historyIndex = commandHistory.count

        // Execute
        onExecute(trimmed)

        // Clear input
        commandText = ""
    }

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
}
```

### Integration into SimulatorView

```swift
struct SimulatorView: View {
    // ... existing state ...

    // Command bar state
    @State private var commandText: String = ""
    @State private var commandHistory: [String] = []
    @State private var terminalFontSize: CGFloat = 9.0

    var body: some View {
        VStack(spacing: 0) {
            // Main 3-column split view
            NavigationSplitView(columnVisibility: $columnVisibility) {
                // ... left column ...
            } content: {
                // ... center column ...
            } detail: {
                // ... right column ...
            }

            // Global command bar at bottom
            TerminalCommandBar(
                commandText: $commandText,
                terminalFontSize: $terminalFontSize,
                commandHistory: $commandHistory,
                onExecute: { command in
                    executeTerminalCommand(command)
                }
            )
        }
    }

    // MARK: - Command Execution

    private func executeTerminalCommand(_ command: String) {
        let parser = TerminalCommandParser()
        let result = parser.parse(command)

        switch result {
        case .create(let type, let params):
            handleCreateCommand(type: type, params: params)
        case .select(let index):
            handleSelectCommand(index: index)
        case .start(let index):
            handleStartCommand(index: index)
        case .stop(let index):
            handleStopCommand(index: index)
        case .list(let filter):
            handleListCommand(filter: filter)
        case .help:
            handleHelpCommand()
        case .unknown:
            handleUnknownCommand(command)
        }
    }
}
```

### Pros
✅ Always accessible (global keyboard shortcut like `:` in vim)
✅ Doesn't compete with visual UI for space
✅ Familiar to terminal/vim users
✅ Can control all views/actions from one place
✅ Command history with up/down arrows

### Cons
❌ Takes up vertical space permanently
❌ Might be intimidating to non-technical users
❌ Requires comprehensive command parser

---

## Approach 2: City Detail View Input (Context-Aware)

### Concept
When viewing a specific city, the terminal input appears **within that city's detail view**, scoped to that city's commands only.

### Visual

```
╔═══ NODE_[00]: ALPHA_CITY ══════════════════╗
║                                            ║
║ STATUS.............: [ACTIVE]              ║
║ COHERENCE..........: [██████░░░░] 0.60     ║
║                                            ║
╟────────────────────────────────────────────╢
║ CONSCIOUSNESS_STREAM                       ║
║ > [REQ] Should I expand...                 ║
║ > [MEM] The old tower...                   ║
╟────────────────────────────────────────────╢
║                                            ║
║ COMMAND: >_____________________________    ║
║                                            ║
╚════════════════════════════════════════════╝
```

### Commands (Scoped to City)

```
> create thought --type=request
> start
> stop
> reset
> delete
> export --format=json
> set coherence 0.8
```

### Implementation

Add to `TerminalCityDetailView.swift`:

```swift
// At bottom of city detail view
VStack(alignment: .leading, spacing: 4) {
    Text("╔═══ COMMAND_INPUT ═══════════════════════╗")
        .font(terminalFont(9))
        .foregroundStyle(Color.green.opacity(0.6))

    HStack(spacing: 8) {
        Text("║")
            .font(terminalFont(9))
            .foregroundStyle(Color.green.opacity(0.6))

        Text(">")
            .font(terminalFont(9, weight: .bold))
            .foregroundStyle(Color.green.opacity(0.9))

        TextField("", text: $commandText)
            .textFieldStyle(.plain)
            .font(terminalFont(9))
            .foregroundStyle(Color.green.opacity(0.9))
            .onSubmit {
                executeCityCommand(commandText, for: city)
                commandText = ""
            }

        Text("║")
            .font(terminalFont(9))
            .foregroundStyle(Color.green.opacity(0.6))
    }

    Text("╚═════════════════════════════════════════╝")
        .font(terminalFont(9))
        .foregroundStyle(Color.green.opacity(0.6))
}
```

### Pros
✅ Context-aware (commands apply to current city)
✅ Feels natural in that specific view
✅ Simpler command set (no need for `city [00]` prefix)
✅ Can have different commands for different views

### Cons
❌ Not accessible from other views
❌ Users might not discover it
❌ Redundant if you also want global commands

---

## Approach 3: Overlay Modal (Toggle On/Off)

### Concept
Press `Cmd+K` (or `:` like vim) to bring up a centered command palette overlay that appears over any view.

### Visual

```
┌──────────────────────────────────────────────┐
│                                              │
│   (dimmed content behind)                    │
│                                              │
│   ╔═══ COMMAND_INTERFACE ═════════════════╗ │
│   ║                                        ║ │
│   ║ > list --filter=active_______________ ║ │
│   ║                                        ║ │
│   ║ SUGGESTIONS:                           ║ │
│   ║  • list [--filter=active|dormant]     ║ │
│   ║  • create city --name=NAME            ║ │
│   ║  • select [00]                        ║ │
│   ║                                        ║ │
│   ╚════════════════════════════════════════╝ │
│                                              │
│                Press ESC to close            │
└──────────────────────────────────────────────┘
```

### Implementation

**File:** `idle_01/ui/terminal/TerminalCommandPalette.swift`

```swift
import SwiftUI

struct TerminalCommandPalette: View {
    @Binding var isPresented: Bool
    @Binding var commandText: String
    @Binding var terminalFontSize: CGFloat

    @State private var suggestions: [String] = []

    let onExecute: (String) -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Command box
            VStack(alignment: .leading, spacing: 0) {
                // Header
                Text("╔═══ COMMAND_INTERFACE ═══════════════════════════╗")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                // Input
                HStack(spacing: 8) {
                    Text("║")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.6))

                    Text(">")
                        .font(terminalFont(9, weight: .bold))
                        .foregroundStyle(Color.green.opacity(0.9))

                    TextField("", text: $commandText)
                        .textFieldStyle(.plain)
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.9))
                        .onSubmit {
                            onExecute(commandText)
                            commandText = ""
                            isPresented = false
                        }
                        .onChange(of: commandText) { _, newValue in
                            updateSuggestions(for: newValue)
                        }

                    Text("║")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.6))
                }
                .padding(.vertical, 8)

                // Divider
                Text("╟─────────────────────────────────────────────────╢")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.4))

                // Suggestions
                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            HStack(spacing: 8) {
                                Text("║")
                                    .font(terminalFont(9))
                                    .foregroundStyle(Color.green.opacity(0.6))

                                Text("•")
                                    .font(terminalFont(8))
                                    .foregroundStyle(Color.green.opacity(0.5))

                                Text(suggestion)
                                    .font(terminalFont(8))
                                    .foregroundStyle(Color.green.opacity(0.7))

                                Spacer()

                                Text("║")
                                    .font(terminalFont(8))
                                    .foregroundStyle(Color.green.opacity(0.6))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Footer
                Text("╚═════════════════════════════════════════════════╝")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                // Help text
                Text("Press ESC to close • TAB for suggestions • ENTER to execute")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.4))
                    .padding(.top, 8)
            }
            .padding(24)
            .background(Color.black)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.green.opacity(0.3), lineWidth: 2)
            )
            .frame(maxWidth: 600)
        }
        .onKeyPress(.escape) {
            isPresented = false
            return .handled
        }
    }

    private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = terminalFontSize / 9.0
        return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
    }

    private func updateSuggestions(for text: String) {
        let allCommands = [
            "help",
            "list",
            "list --filter=active",
            "list --filter=dormant",
            "create city --name=NAME",
            "select [00]",
            "start [00]",
            "stop [00]",
            "delete [00]",
            "export --format=json"
        ]

        if text.isEmpty {
            suggestions = allCommands.prefix(5).map { $0 }
        } else {
            suggestions = allCommands.filter { $0.contains(text.lowercased()) }
        }
    }
}
```

### Integration

```swift
struct SimulatorView: View {
    @State private var showCommandPalette = false
    @State private var commandText = ""

    var body: some View {
        ZStack {
            // Main UI
            NavigationSplitView(...) { ... }

            // Command palette overlay
            if showCommandPalette {
                TerminalCommandPalette(
                    isPresented: $showCommandPalette,
                    commandText: $commandText,
                    terminalFontSize: $terminalFontSize,
                    onExecute: executeTerminalCommand
                )
            }
        }
        // Global keyboard shortcut
        .onKeyPress("k", modifiers: .command) {
            showCommandPalette.toggle()
            return .handled
        }
        .onKeyPress(":", modifiers: []) { // Like vim
            showCommandPalette = true
            return .handled
        }
    }
}
```

### Pros
✅ Non-intrusive (hidden by default)
✅ Accessible from anywhere
✅ Can show helpful suggestions/autocomplete
✅ Familiar to command palette users (VS Code, Spotlight)
✅ Doesn't take permanent screen space

### Cons
❌ Requires keyboard shortcut discovery
❌ Context less obvious (need prefixes like `city [00]`)
❌ More complex implementation (overlay management)

---

## Approach 4: Hybrid - Bottom Bar + Contextual

### Concept
Combine approaches:
- **Global bottom bar** for system-wide commands
- **Context-aware shortcuts** that auto-populate the bar with city-specific commands when viewing a city

### Visual - No Selection

```
╔═══════════════════════════════════════════════════╗
║ > help___________________________________________ ║
╚═══════════════════════════════════════════════════╝
```

### Visual - City Selected

```
╔═══ NODE_[00] ═════════════════════════════════════╗
║ > start [00]_____________________________________ ║
╚═══════════════════════════════════════════════════╝
     ^auto-filled with city index
```

### Implementation

The command bar knows the current context and offers smart autocomplete:

```swift
struct ContextAwareCommandBar: View {
    @Binding var selectedCityID: PersistentIdentifier?
    @Binding var commandText: String

    var body: some View {
        TerminalCommandBar(
            commandText: $commandText,
            placeholder: placeholder,
            suggestions: suggestions,
            onExecute: executeCommand
        )
    }

    private var placeholder: String {
        if let cityID = selectedCityID {
            return "Commands for selected city..."
        } else {
            return "Global commands..."
        }
    }

    private var suggestions: [String] {
        if selectedCityID != nil {
            return ["start", "stop", "create thought", "reset", "delete"]
        } else {
            return ["list", "create city", "help", "export"]
        }
    }
}
```

### Pros
✅ Best of both worlds (global + contextual)
✅ Smart autocomplete based on context
✅ Always visible and accessible
✅ Learns your current focus automatically

### Cons
❌ Most complex to implement
❌ Behavior might be confusing if context changes unexpectedly

---

## Command Language Design

Regardless of placement, you need a consistent command syntax:

### Core Commands

```bash
# System
help                          # Show all commands
help <command>                # Show specific command help
list                          # List all cities
list --filter=active          # List only active cities
list --filter=dormant         # List only dormant cities

# City Management
create city --name=NAME       # Create new city
select [00]                   # Select city by index
select ALPHA                  # Select city by name (case-insensitive)
delete [00]                   # Delete city

# City Control
start [00]                    # Start city simulation
stop [00]                     # Stop city simulation
reset [00]                    # Reset city to initial state

# Thought/Item Management
create thought                # Create new thought for current city
create thought --type=request # Create specific thought type
respond [00] "text"           # Respond to thought index
dismiss [00]                  # Dismiss thought

# Data
export --format=json          # Export all data
export [00] --format=json     # Export specific city
stats                         # Show global statistics
stats [00]                    # Show city statistics

# Settings
set coherence 0.8             # Set resource value (context-aware)
set crt on                    # Toggle CRT flicker
set font 12                   # Set font size
```

### Command Parser

**File:** `idle_01/core/TerminalCommandParser.swift`

```swift
import Foundation

struct TerminalCommandParser {

    func parse(_ input: String) -> TerminalCommand {
        let components = input.split(separator: " ").map { String($0) }
        guard let verb = components.first?.lowercased() else {
            return .unknown
        }

        switch verb {
        case "help":
            return .help(topic: components.count > 1 ? components[1] : nil)

        case "list":
            let filter = extractFlag(from: components, flag: "--filter")
            return .list(filter: filter)

        case "create":
            guard components.count > 1 else { return .unknown }
            let type = components[1].lowercased()

            if type == "city" {
                let name = extractFlag(from: components, flag: "--name") ?? "unnamed"
                return .createCity(name: name)
            } else if type == "thought" {
                let thoughtType = extractFlag(from: components, flag: "--type")
                return .createThought(type: thoughtType)
            }
            return .unknown

        case "select":
            guard components.count > 1 else { return .unknown }
            let target = components[1]
            return .select(target: target)

        case "start":
            let target = components.count > 1 ? components[1] : nil
            return .start(target: target)

        case "stop":
            let target = components.count > 1 ? components[1] : nil
            return .stop(target: target)

        case "delete":
            guard components.count > 1 else { return .unknown }
            return .delete(target: components[1])

        case "export":
            let format = extractFlag(from: components, flag: "--format") ?? "json"
            let target = components.count > 1 && !components[1].hasPrefix("--") ? components[1] : nil
            return .export(target: target, format: format)

        case "stats":
            let target = components.count > 1 ? components[1] : nil
            return .stats(target: target)

        case "set":
            guard components.count > 2 else { return .unknown }
            let key = components[1]
            let value = components[2]
            return .set(key: key, value: value)

        default:
            return .unknown
        }
    }

    private func extractFlag(from components: [String], flag: String) -> String? {
        guard let index = components.firstIndex(where: { $0 == flag }),
              index + 1 < components.count else {
            return nil
        }
        return components[index + 1]
    }
}

enum TerminalCommand {
    case help(topic: String?)
    case list(filter: String?)
    case createCity(name: String)
    case createThought(type: String?)
    case select(target: String)
    case start(target: String?)
    case stop(target: String?)
    case delete(target: String)
    case export(target: String?, format: String)
    case stats(target: String?)
    case set(key: String, value: String)
    case unknown
}
```

---

## Recommendation: Start with Approach 1 (Global Bottom Bar)

**Why:**
1. **Always accessible** - Users can type commands from any view
2. **Clear separation** - Terminal is a parallel interface to mouse/UI
3. **Familiar pattern** - Every terminal app has input at bottom
4. **Easiest to implement** - Single component, clear integration point
5. **Expandable** - Can add context-awareness later if needed

### Implementation Priority

**Phase 1: Basic Command Bar**
- Input field at bottom with ASCII borders
- Basic command parser (help, list, create city, select)
- Command history (up/down arrows)
- Execute on Enter

**Phase 2: Command Execution**
- Wire up commands to actual actions
- Show feedback (success/error messages)
- Add more commands (start/stop/delete)

**Phase 3: Smart Features**
- Autocomplete/suggestions
- Tab completion
- Command aliases (shortcuts)
- Error messages in terminal style

**Phase 4: Polish**
- Command output log (scrollable history above input)
- Syntax highlighting for commands
- Keyboard shortcuts for common commands
- Persistent command history across sessions

---

## Output/Feedback Display

Where do command results appear?

### Option A: Toast Notifications (Minimal)

```
╔═══════════════════════════════════════════════════╗
║ > create city --name=DELTA                        ║
╚═══════════════════════════════════════════════════╝

[Notification appears briefly]
>> CITY_CREATED: DELTA [INDEX: 03]
```

Brief message that fades after 2-3 seconds.

### Option B: Output Log Above Input (Terminal-Style)

```
╔═══ OUTPUT ═════════════════════════════════════════╗
║ >> CITY_CREATED: DELTA [INDEX: 03]                ║
║ >> SELECT: DELTA [00] ACTIVE                       ║
║ >> START: CITY_ALPHA [00]                          ║
╚════════════════════════════════════════════════════╝
╔═══ INPUT ══════════════════════════════════════════╗
║ > list --filter=active___________________________ ║
╚════════════════════════════════════════════════════╝
```

Persistent scrollable log of recent commands and their output.

**Recommended:** Option B for authentic terminal feel.

---

## Keyboard Shortcuts

Make terminal power-user friendly:

```
Cmd+L      - Focus command input (from anywhere)
Cmd+K      - Clear command input
Esc        - Blur command input / cancel
↑          - Previous command (history)
↓          - Next command (history)
Tab        - Autocomplete current suggestion
Ctrl+C     - Cancel current input
Enter      - Execute command
```

---

## Complete Example: Global Bottom Bar

**File:** `idle_01/ui/terminal/TerminalCommandInterface.swift`

```swift
import SwiftUI
import SwiftData

struct TerminalCommandInterface: View {
    @Binding var terminalFontSize: CGFloat
    @Environment(\.modelContext) private var modelContext

    @State private var commandText: String = ""
    @State private var commandHistory: [String] = []
    @State private var outputHistory: [CommandOutput] = []
    @State private var historyIndex: Int = 0
    @State private var cursorBlink: Bool = false
    @FocusState private var isInputFocused: Bool

    // Context
    @Binding var selectedCityID: PersistentIdentifier?
    @Query private var allCities: [City]

    var body: some View {
        VStack(spacing: 0) {
            // Output log (scrollable)
            if !outputHistory.isEmpty {
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(outputHistory.suffix(10)) { output in
                                outputRow(output)
                                    .id(output.id)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .onChange(of: outputHistory.count) { _, _ in
                            if let last = outputHistory.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(height: 80)
                .background(Color.black)
            }

            // Input bar
            VStack(spacing: 0) {
                Text("╔" + String(repeating: "═", count: 96) + "╗")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                HStack(spacing: 4) {
                    Text("║")
                    Text(">")
                        .font(terminalFont(9, weight: .bold))
                        .foregroundStyle(Color.green.opacity(0.9))

                    TextField("", text: $commandText, prompt: promptText)
                        .textFieldStyle(.plain)
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.9))
                        .focused($isInputFocused)
                        .onSubmit { executeCommand() }

                    Text("║")
                }
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))
                .padding(.vertical, 6)

                Text("╚" + String(repeating: "═", count: 96) + "╝")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))
            }
            .background(Color.black)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                cursorBlink = true
            }
        }
        .onKeyPress(.upArrow) { navigateHistory(.up); return .handled }
        .onKeyPress(.downArrow) { navigateHistory(.down); return .handled }
    }

    // MARK: - Views

    private var promptText: Text {
        Text("COMMAND_INPUT...")
            .font(terminalFont(9))
            .foregroundStyle(Color.green.opacity(0.4))
    }

    private func outputRow(_ output: CommandOutput) -> some View {
        HStack(spacing: 4) {
            Text(">>")
                .font(terminalFont(8))
                .foregroundStyle(Color.green.opacity(0.5))

            Text(output.text)
                .font(terminalFont(8))
                .foregroundStyle(output.isError ? Color.orange.opacity(0.8) : Color.green.opacity(0.7))
        }
    }

    // MARK: - Command Execution

    private func executeCommand() {
        let trimmed = commandText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Add to history
        commandHistory.append(trimmed)
        historyIndex = commandHistory.count

        // Parse and execute
        let parser = TerminalCommandParser()
        let command = parser.parse(trimmed)

        let result = handleCommand(command)
        outputHistory.append(result)

        // Clear input
        commandText = ""
    }

    private func handleCommand(_ command: TerminalCommand) -> CommandOutput {
        switch command {
        case .help(let topic):
            return handleHelp(topic: topic)
        case .list(let filter):
            return handleList(filter: filter)
        case .createCity(let name):
            return handleCreateCity(name: name)
        case .select(let target):
            return handleSelect(target: target)
        case .start(let target):
            return handleStart(target: target)
        case .unknown:
            return CommandOutput(text: "UNKNOWN_COMMAND. Type 'help' for available commands.", isError: true)
        default:
            return CommandOutput(text: "COMMAND_NOT_IMPLEMENTED", isError: true)
        }
    }

    // Command handlers...

    private func handleCreateCity(name: String) -> CommandOutput {
        let city = City(name: name, parameters: [:])
        modelContext.insert(city)
        let index = allCities.count - 1
        return CommandOutput(text: "CITY_CREATED: \(name.uppercased()) [INDEX: \(String(format: "%02d", index))]")
    }

    private func handleList(filter: String?) -> CommandOutput {
        let filtered = filter == "active" ? allCities.filter { $0.isRunning } :
                      filter == "dormant" ? allCities.filter { !$0.isRunning } :
                      allCities

        let list = filtered.enumerated().map { index, city in
            let status = city.isRunning ? "●" : "○"
            return "[\(String(format: "%02d", index))] \(status) \(city.name.uppercased())"
        }.joined(separator: " | ")

        return CommandOutput(text: "NODES: \(list)")
    }

    private func handleHelp(topic: String?) -> CommandOutput {
        let help = """
        AVAILABLE_COMMANDS:
        • help - Show this message
        • list [--filter=active|dormant] - List all cities
        • create city --name=NAME - Create new city
        • select [00] - Select city by index
        • start [00] - Start city simulation
        • stop [00] - Stop city simulation
        """
        return CommandOutput(text: help)
    }

    // MARK: - Helpers

    private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = terminalFontSize / 9.0
        return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
    }

    private func navigateHistory(_ direction: Direction) {
        guard !commandHistory.isEmpty else { return }

        switch direction {
        case .up:
            if historyIndex > 0 {
                historyIndex -= 1
                commandText = commandHistory[historyIndex]
            }
        case .down:
            if historyIndex < commandHistory.count {
                historyIndex += 1
                commandText = historyIndex < commandHistory.count ? commandHistory[historyIndex] : ""
            }
        }
    }

    enum Direction { case up, down }
}

struct CommandOutput: Identifiable {
    let id = UUID()
    let text: String
    let isError: Bool = false
}
```

---

## Final Recommendation

**Implement Approach 1 (Global Bottom Bar) with these features:**

1. ✅ Persistent command input at bottom of window
2. ✅ Scrollable output log above input (last 10 commands)
3. ✅ Command history with ↑/↓ arrows
4. ✅ Comprehensive command parser
5. ✅ Context-aware commands (knows which city is selected)
6. ✅ Error messages in terminal style
7. ✅ Keyboard shortcut (Cmd+L) to focus input

This gives you a complete parallel interface to the mouse/UI that feels authentic to terminal UIs while being practical and powerful.

---

**INTERFACE: TERMINAL_COMMAND_INPUT**
**DOCUMENT_VERSION: 1.0**
**STATUS: [READY_FOR_IMPLEMENTATION]**
**// █**
