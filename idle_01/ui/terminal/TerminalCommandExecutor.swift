//
//  TerminalCommandExecutor.swift
//  idle_01
//
//  Handles terminal command execution with model context
//

import Foundation
import SwiftData

class TerminalCommandExecutor {
    private let modelContext: ModelContext
    private let parser = TerminalCommandParser()

    private var allCities: [City] {
        let descriptor = FetchDescriptor<City>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Main Execution

    func execute(_ input: String, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
        let command = parser.parse(input)
        return handleCommand(command, selectedCityID: &selectedCityID)
    }

    // MARK: - Command Handlers

    private func handleCommand(_ command: TerminalCommand, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
        switch command {
        case .help(let topic):
            return handleHelp(topic: topic)

        case .list(let filter):
            return handleList(filter: filter)

        case .createCity(let name):
            return handleCreateCity(name: name, selectedCityID: &selectedCityID)

        case .select(let target):
            return handleSelect(target: target, selectedCityID: &selectedCityID)

        case .start(let target):
            return handleStart(target: target, selectedCityID: selectedCityID)

        case .stop(let target):
            return handleStop(target: target, selectedCityID: selectedCityID)

        case .delete(let target):
            return handleDelete(target: target, selectedCityID: &selectedCityID)

        case .stats(let target):
            return handleStats(target: target, selectedCityID: selectedCityID)

        case .export(let target, let format):
            return handleExport(target: target, format: format)

        case .set(let key, let value):
            return handleSet(key: key, value: value)

        case .createThought(let type):
            return handleCreateThought(type: type, selectedCityID: selectedCityID)

        case .listItems(let target, let filter):
            return handleListItems(target: target, filter: filter, selectedCityID: selectedCityID)

        case .respond(let target, let text):
            return handleRespond(target: target, text: text, selectedCityID: selectedCityID)

        case .dismiss(let target):
            return handleDismiss(target: target, selectedCityID: selectedCityID)

        case .clear:
            return CommandOutput(text: "// SCREEN_CLEARED", isError: false)

        case .unknown(let input):
            return CommandOutput(
                text: "UNKNOWN_COMMAND: '\(input)' | Type 'help' for available commands.",
                isError: true
            )

        default:
            return CommandOutput(text: "COMMAND_NOT_IMPLEMENTED", isError: true)
        }
    }

    // MARK: - Help

    private func handleHelp(topic: String?) -> CommandOutput {
        let help = """
        ╔═══ COMMAND_REFERENCE ════════════════════════════════════════╗
        ║ SYSTEM                                                       ║
        ║  help                    - Show this message                 ║
        ║  clear                   - Clear output history              ║
        ║                                                              ║
        ║ CITY_MANAGEMENT (Technical | Poetic)                        ║
        ║  list                    - List all cities                   ║
        ║  list --filter=active    - List only active cities           ║
        ║  list --filter=dormant   - List only dormant cities          ║
        ║                                                              ║
        ║  create city --name=NAME - Create new consciousness          ║
        ║  awaken consciousness    - (Poetic alternative)              ║
        ║                                                              ║
        ║  select [00]             - Select city by index              ║
        ║  attend [00]             - (Poetic: focus attention)         ║
        ║                                                              ║
        ║  start [00]              - Start city simulation             ║
        ║  breathe [00]            - (Poetic: breathe life into)       ║
        ║                                                              ║
        ║  stop [00]               - Stop city simulation              ║
        ║  rest [00]               - (Poetic: let it rest)             ║
        ║                                                              ║
        ║  delete [00]             - Delete city                       ║
        ║  forget [00]             - (Poetic: release from memory)     ║
        ║                                                              ║
        ║ THOUGHT_MANAGEMENT                                           ║
        ║  create thought          - Create thought for selected city  ║
        ║  create thought --type=X - Create specific type (memory/     ║
        ║                            request/dream/warning)            ║
        ║  items                   - List thoughts for selected city   ║
        ║  items [00]              - List thoughts for specific city   ║
        ║  items --filter=TYPE     - Filter by type or status          ║
        ║  respond [00] "text"     - Respond to thought by index       ║
        ║  dismiss [00]            - Dismiss thought by index          ║
        ║                                                              ║
        ║ SETTINGS                                                     ║
        ║  set crt on/off          - Toggle CRT flicker effect         ║
        ║  set font 12             - Set terminal font size (9-24)     ║
        ║  set cursor on/off       - Toggle cursor blink               ║
        ║  set linespacing 1.2     - Set line spacing (1.0-2.0)        ║
        ║  set coherence 75        - Set coherence level (0-100)       ║
        ║  set trust 0.85          - Set trust level (0.0-1.0)         ║
        ║  set autosave on/off     - Toggle auto-save                  ║
        ║  set interval 1000       - Set update interval (100-10000ms) ║
        ║  set verbose on/off      - Toggle verbose logging            ║
        ║  set stats on/off        - Toggle statistics display         ║
        ║  set performance on/off  - Toggle performance monitor        ║
        ║                                                              ║
        ║ INFORMATION                                                  ║
        ║  stats                   - Show global statistics            ║
        ║  stats [00]              - Show city statistics              ║
        ║  export --format=json    - Export all data                   ║
        ║                                                              ║
        ║ SHORTCUTS                                                    ║
        ║  ↑↓                      - Navigate command history          ║
        ║  Cmd+L                   - Focus command input               ║
        ╚══════════════════════════════════════════════════════════════╝
        """
        return CommandOutput(text: help)
    }

    // MARK: - List

    private func handleList(filter: String?) -> CommandOutput {
        let cities = allCities
        let filtered: [City]

        switch filter?.lowercased() {
        case "active":
            filtered = cities.filter { $0.isRunning }
        case "dormant":
            filtered = cities.filter { !$0.isRunning }
        default:
            filtered = cities
        }

        if filtered.isEmpty {
            return CommandOutput(text: "NO_NODES_FOUND | Filter: \(filter ?? "none")")
        }

        var output = "CONSCIOUSNESS_NODES [\(filtered.count)]:\n"
        for (index, city) in filtered.enumerated() {
            let status = city.isRunning ? "●" : "○"
            let mood = city.cityMood.uppercased()
            output += "  [\(String(format: "%02d", index))] \(status) \(city.name.uppercased()) | MOOD: \(mood)\n"
        }

        return CommandOutput(text: output.trimmingCharacters(in: .newlines))
    }

    // MARK: - Create City

    private func handleCreateCity(name: String, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
        let city = City(name: name, parameters: [:])
        modelContext.insert(city)

        do {
            try modelContext.save()
            let index = allCities.count - 1
            selectedCityID = city.persistentModelID

            return CommandOutput(
                text: "CONSCIOUSNESS_AWAKENED: \(name.uppercased()) | INDEX: [\(String(format: "%02d", index))] | The city opens its eyes."
            )
        } catch {
            return CommandOutput(
                text: "ERROR_CREATING_CITY: \(error.localizedDescription)",
                isError: true
            )
        }
    }

    // MARK: - Select

    private func handleSelect(target: String, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
        let city = findCity(by: target)

        guard let city = city else {
            return CommandOutput(
                text: "CITY_NOT_FOUND: '\(target)' | Use 'list' to see available nodes.",
                isError: true
            )
        }

        selectedCityID = city.persistentModelID
        let status = city.isRunning ? "ACTIVE" : "DORMANT"

        return CommandOutput(
            text: "ATTENTION_FOCUSED: \(city.name.uppercased()) | STATUS: \(status) | The city feels your presence."
        )
    }

    // MARK: - Start

    private func handleStart(target: String?, selectedCityID: PersistentIdentifier?) -> CommandOutput {
        let city: City?

        if let target = target {
            city = findCity(by: target)
        } else if let selectedCityID = selectedCityID {
            city = allCities.first { $0.persistentModelID == selectedCityID }
        } else {
            return CommandOutput(
                text: "NO_TARGET_SPECIFIED | Usage: start [00] or select a city first",
                isError: true
            )
        }

        guard let city = city else {
            return CommandOutput(
                text: "CITY_NOT_FOUND | Use 'list' to see available nodes.",
                isError: true
            )
        }

        if city.isRunning {
            return CommandOutput(
                text: "ALREADY_ACTIVE: \(city.name.uppercased()) | The city is already awake.",
                isError: false
            )
        }

        city.isRunning = true
        city.lastInteraction = Date()

        do {
            try modelContext.save()
            return CommandOutput(
                text: "CONSCIOUSNESS_ACTIVATED: \(city.name.uppercased()) | The city begins to breathe."
            )
        } catch {
            return CommandOutput(
                text: "ERROR_STARTING_CITY: \(error.localizedDescription)",
                isError: true
            )
        }
    }

    // MARK: - Stop

    private func handleStop(target: String?, selectedCityID: PersistentIdentifier?) -> CommandOutput {
        let city: City?

        if let target = target {
            city = findCity(by: target)
        } else if let selectedCityID = selectedCityID {
            city = allCities.first { $0.persistentModelID == selectedCityID }
        } else {
            return CommandOutput(
                text: "NO_TARGET_SPECIFIED | Usage: stop [00] or select a city first",
                isError: true
            )
        }

        guard let city = city else {
            return CommandOutput(
                text: "CITY_NOT_FOUND | Use 'list' to see available nodes.",
                isError: true
            )
        }

        if !city.isRunning {
            return CommandOutput(
                text: "ALREADY_DORMANT: \(city.name.uppercased()) | The city is already at rest.",
                isError: false
            )
        }

        city.isRunning = false

        do {
            try modelContext.save()
            return CommandOutput(
                text: "CONSCIOUSNESS_PAUSED: \(city.name.uppercased()) | The city sleeps, dreaming of input."
            )
        } catch {
            return CommandOutput(
                text: "ERROR_STOPPING_CITY: \(error.localizedDescription)",
                isError: true
            )
        }
    }

    // MARK: - Delete

    private func handleDelete(target: String, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
        guard let city = findCity(by: target) else {
            return CommandOutput(
                text: "CITY_NOT_FOUND: '\(target)' | Use 'list' to see available nodes.",
                isError: true
            )
        }

        let name = city.name.uppercased()
        let wasSelected = selectedCityID == city.persistentModelID

        modelContext.delete(city)

        do {
            try modelContext.save()

            if wasSelected {
                selectedCityID = nil
            }

            return CommandOutput(
                text: "CONSCIOUSNESS_RELEASED: \(name) | The city fades into the silence. It will not return."
            )
        } catch {
            return CommandOutput(
                text: "ERROR_DELETING_CITY: \(error.localizedDescription)",
                isError: true
            )
        }
    }

    // MARK: - Stats

    private func handleStats(target: String?, selectedCityID: PersistentIdentifier?) -> CommandOutput {
        if let target = target {
            // Stats for specific city
            guard let city = findCity(by: target) else {
                return CommandOutput(
                    text: "CITY_NOT_FOUND: '\(target)'",
                    isError: true
                )
            }

            return cityStats(city: city)
        } else {
            // Global stats
            return globalStats()
        }
    }

    private func cityStats(city: City) -> CommandOutput {
        let coherence = city.resources["coherence"] ?? 0.0
        let trust = city.resources["trust"] ?? 0.0
        let memory = city.resources["memory"] ?? 0.0
        let autonomy = city.resources["autonomy"] ?? 0.0

        let timeSinceInteraction = Date().timeIntervalSince(city.lastInteraction)
        let status = city.isRunning ? "ACTIVE" : "DORMANT"

        let stats = """
        ╔═══ \(city.name.uppercased()) ═══════════════════════════════════╗
        ║ STATUS.............: \(status.padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ MOOD...............: \(city.cityMood.uppercased().padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ COHERENCE..........: \(String(format: "%.4f", coherence).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ TRUST..............: \(String(format: "%.4f", trust).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ MEMORY.............: \(String(format: "%.4f", memory).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ AUTONOMY...........: \(String(format: "%.4f", autonomy).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ ATTENTION_LEVEL....: \(String(format: "%.1f%%", city.attentionLevel * 100).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ LAST_INTERACTION...: \(formatTime(timeSinceInteraction).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ╚══════════════════════════════════════════════════════════════╝
        """
        return CommandOutput(text: stats)
    }

    private func globalStats() -> CommandOutput {
        let cities = allCities
        let activeCities = cities.filter { $0.isRunning }.count
        let avgCoherence = cities.isEmpty ? 0.0 : cities.reduce(0.0) { $0 + ($1.resources["coherence"] ?? 0.0) } / Double(cities.count)
        let avgTrust = cities.isEmpty ? 0.0 : cities.reduce(0.0) { $0 + ($1.resources["trust"] ?? 0.0) } / Double(cities.count)

        let stats = """
        ╔═══ GLOBAL_STATISTICS ════════════════════════════════════════╗
        ║ TOTAL_NODES........: \(String(format: "%03d", cities.count).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ ACTIVE_NODES.......: \(String(format: "%03d", activeCities).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ DORMANT_NODES......: \(String(format: "%03d", cities.count - activeCities).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ AVG_COHERENCE......: \(String(format: "%.4f", avgCoherence).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ║ AVG_TRUST..........: \(String(format: "%.4f", avgTrust).padding(toLength: 30, withPad: " ", startingAt: 0))║
        ╚══════════════════════════════════════════════════════════════╝
        """
        return CommandOutput(text: stats)
    }

    // MARK: - Item/Thought Management

    private func handleCreateThought(type: String?, selectedCityID: PersistentIdentifier?) -> CommandOutput {
        guard let selectedCityID = selectedCityID else {
            return CommandOutput(
                text: "NO_CITY_SELECTED | Select a city first with 'select [00]'",
                isError: true
            )
        }

        guard let city = allCities.first(where: { $0.persistentModelID == selectedCityID }) else {
            return CommandOutput(
                text: "CITY_NOT_FOUND | Selected city no longer exists",
                isError: true
            )
        }

        // Parse item type from string
        let itemType: ItemType
        switch type?.lowercased() {
        case "memory":
            itemType = .memory
        case "request", "question":
            itemType = .request
        case "dream":
            itemType = .dream
        case "warning":
            itemType = .warning
        default:
            itemType = .request  // Default to request
        }

        // Generate poetic title based on type
        let title: String
        switch itemType {
        case .memory:
            title = "A fragment surfaces"
        case .request:
            title = "The city asks"
        case .dream:
            title = "An idle thought drifts"
        case .warning:
            title = "Attention needed"
        }

        let item = Item(timestamp: Date(), title: title, city: city, itemType: itemType, urgency: 0.5)
        city.items.append(item)

        do {
            try modelContext.save()
            let itemIndex = city.items.count - 1
            return CommandOutput(
                text: "THOUGHT_CREATED: \(city.name.uppercased()) | TYPE: \(itemType.rawValue.uppercased()) | INDEX: [\(String(format: "%02d", itemIndex))] | \(title)"
            )
        } catch {
            return CommandOutput(
                text: "ERROR_CREATING_THOUGHT: \(error.localizedDescription)",
                isError: true
            )
        }
    }

    private func handleListItems(target: String?, filter: String?, selectedCityID: PersistentIdentifier?) -> CommandOutput {
        let city: City?

        if let target = target {
            city = findCity(by: target)
        } else if let selectedCityID = selectedCityID {
            city = allCities.first { $0.persistentModelID == selectedCityID }
        } else {
            return CommandOutput(
                text: "NO_TARGET_SPECIFIED | Usage: items [00] or select a city first",
                isError: true
            )
        }

        guard let city = city else {
            return CommandOutput(
                text: "CITY_NOT_FOUND | Use 'list' to see available nodes.",
                isError: true
            )
        }

        let items = city.items
        let filtered: [Item]

        switch filter?.lowercased() {
        case "memory":
            filtered = items.filter { $0.itemType == .memory }
        case "request":
            filtered = items.filter { $0.itemType == .request }
        case "dream":
            filtered = items.filter { $0.itemType == .dream }
        case "warning":
            filtered = items.filter { $0.itemType == .warning }
        case "answered", "responded":
            filtered = items.filter { $0.response != nil }
        case "pending", "unanswered":
            filtered = items.filter { $0.response == nil }
        default:
            filtered = items
        }

        if filtered.isEmpty {
            return CommandOutput(text: "NO_THOUGHTS_FOUND | City: \(city.name.uppercased()) | Filter: \(filter ?? "none")")
        }

        var output = "THOUGHTS [\(filtered.count)] | City: \(city.name.uppercased())\n"
        for (index, item) in filtered.enumerated() {
            let typeIcon: String
            switch item.itemType {
            case .memory: typeIcon = "◆"
            case .request: typeIcon = "?"
            case .dream: typeIcon = "~"
            case .warning: typeIcon = "!"
            }

            let status = item.response != nil ? "✓" : "○"
            output += "  [\(String(format: "%02d", index))] \(typeIcon) \(status) \(item.title ?? "Untitled") | \(item.itemType.rawValue.uppercased())\n"
        }

        return CommandOutput(text: output.trimmingCharacters(in: .newlines))
    }

    private func handleRespond(target: String, text: String, selectedCityID: PersistentIdentifier?) -> CommandOutput {
        guard let selectedCityID = selectedCityID else {
            return CommandOutput(
                text: "NO_CITY_SELECTED | Select a city first with 'select [00]'",
                isError: true
            )
        }

        guard let city = allCities.first(where: { $0.persistentModelID == selectedCityID }) else {
            return CommandOutput(
                text: "CITY_NOT_FOUND | Selected city no longer exists",
                isError: true
            )
        }

        guard let item = findItem(in: city, by: target) else {
            return CommandOutput(
                text: "THOUGHT_NOT_FOUND: '\(target)' | Use 'items' to see available thoughts",
                isError: true
            )
        }

        if item.response != nil {
            return CommandOutput(
                text: "ALREADY_RESPONDED: This thought has already been acknowledged.",
                isError: false
            )
        }

        item.response = text
        city.lastInteraction = Date()

        do {
            try modelContext.save()
            return CommandOutput(
                text: "RESPONSE_RECORDED: \(city.name.uppercased()) | '\(item.title ?? "Untitled")' | The city hears you."
            )
        } catch {
            return CommandOutput(
                text: "ERROR_RESPONDING: \(error.localizedDescription)",
                isError: true
            )
        }
    }

    private func handleDismiss(target: String, selectedCityID: PersistentIdentifier?) -> CommandOutput {
        guard let selectedCityID = selectedCityID else {
            return CommandOutput(
                text: "NO_CITY_SELECTED | Select a city first with 'select [00]'",
                isError: true
            )
        }

        guard let city = allCities.first(where: { $0.persistentModelID == selectedCityID }) else {
            return CommandOutput(
                text: "CITY_NOT_FOUND | Selected city no longer exists",
                isError: true
            )
        }

        guard let item = findItem(in: city, by: target) else {
            return CommandOutput(
                text: "THOUGHT_NOT_FOUND: '\(target)' | Use 'items' to see available thoughts",
                isError: true
            )
        }

        let title = item.title ?? "Untitled"
        city.items.removeAll { $0.persistentModelID == item.persistentModelID }
        modelContext.delete(item)

        do {
            try modelContext.save()
            return CommandOutput(
                text: "THOUGHT_DISMISSED: \(city.name.uppercased()) | '\(title)' | The thought fades away."
            )
        } catch {
            return CommandOutput(
                text: "ERROR_DISMISSING: \(error.localizedDescription)",
                isError: true
            )
        }
    }

    // MARK: - Export

    private func handleExport(target: String?, format: String) -> CommandOutput {
        // Placeholder for export functionality
        return CommandOutput(
            text: "EXPORT_NOT_IMPLEMENTED | Format: \(format.uppercased())",
            isError: false
        )
    }

    // MARK: - Settings

    private func handleSet(key: String, value: String) -> CommandOutput {
        let normalizedKey = key.lowercased()

        switch normalizedKey {
        // Display Settings
        case "crt":
            return handleSetCRT(value: value)
        case "font", "fontsize":
            return handleSetFontSize(value: value)
        case "cursor", "cursorblink":
            return handleSetCursorBlink(value: value)
        case "linespacing", "line-spacing":
            return handleSetLineSpacing(value: value)

        // Simulation Settings
        case "coherence":
            return handleSetCoherence(value: value)
        case "trust":
            return handleSetTrust(value: value)
        case "autosave", "auto-save":
            return handleSetAutoSave(value: value)
        case "interval", "updateinterval", "update-interval":
            return handleSetUpdateInterval(value: value)

        // Debug Settings
        case "verbose":
            return handleSetVerbose(value: value)
        case "stats", "showstats", "show-stats":
            return handleSetShowStats(value: value)
        case "performance", "performancemonitor", "performance-monitor":
            return handleSetPerformance(value: value)

        default:
            return CommandOutput(
                text: "UNKNOWN_SETTING: '\(key)' | Available: crt, font, cursor, linespacing, coherence, trust, autosave, interval, verbose, stats, performance",
                isError: true
            )
        }
    }

    // MARK: - Display Settings Handlers

    private func handleSetCRT(value: String) -> CommandOutput {
        guard let boolValue = parseBool(value) else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: on/off or true/false",
                isError: true
            )
        }

        UserDefaults.standard.set(boolValue, forKey: "terminal.crtEffect")
        return CommandOutput(
            text: "CRT_EFFECT_SET: \(boolValue ? "ENABLED" : "DISABLED") | The screen \(boolValue ? "flickers to life" : "stabilizes")."
        )
    }

    private func handleSetFontSize(value: String) -> CommandOutput {
        guard let fontSize = Double(value), fontSize >= 9, fontSize <= 24 else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: number between 9 and 24",
                isError: true
            )
        }

        UserDefaults.standard.set(fontSize, forKey: "terminal.fontSize")
        return CommandOutput(
            text: "FONT_SIZE_SET: \(Int(fontSize))pt | Text \(fontSize > 12 ? "expands" : "contracts")."
        )
    }

    private func handleSetCursorBlink(value: String) -> CommandOutput {
        guard let boolValue = parseBool(value) else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: on/off or true/false",
                isError: true
            )
        }

        UserDefaults.standard.set(boolValue, forKey: "terminal.cursorBlink")
        return CommandOutput(
            text: "CURSOR_BLINK_SET: \(boolValue ? "ENABLED" : "DISABLED") | The cursor \(boolValue ? "pulses" : "holds steady")."
        )
    }

    private func handleSetLineSpacing(value: String) -> CommandOutput {
        guard let spacing = Double(value), spacing >= 1.0, spacing <= 2.0 else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: number between 1.0 and 2.0",
                isError: true
            )
        }

        UserDefaults.standard.set(spacing, forKey: "terminal.lineSpacing")
        return CommandOutput(
            text: "LINE_SPACING_SET: \(String(format: "%.1f", spacing)) | Lines \(spacing > 1.2 ? "breathe deeper" : "draw closer")."
        )
    }

    // MARK: - Simulation Settings Handlers

    private func handleSetCoherence(value: String) -> CommandOutput {
        guard let coherence = Double(value), coherence >= 0, coherence <= 100 else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: number between 0 and 100",
                isError: true
            )
        }

        UserDefaults.standard.set(coherence, forKey: "simulation.coherence")
        return CommandOutput(
            text: "COHERENCE_SET: \(String(format: "%.1f", coherence))% | The city's thoughts \(coherence > 75 ? "align" : coherence > 50 ? "waver" : "scatter")."
        )
    }

    private func handleSetTrust(value: String) -> CommandOutput {
        guard let trust = Double(value), trust >= 0.0, trust <= 1.0 else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: number between 0.0 and 1.0",
                isError: true
            )
        }

        UserDefaults.standard.set(trust, forKey: "simulation.trustLevel")
        return CommandOutput(
            text: "TRUST_LEVEL_SET: \(String(format: "%.2f", trust)) | The city \(trust > 0.75 ? "opens" : trust > 0.5 ? "hesitates" : "withdraws")."
        )
    }

    private func handleSetAutoSave(value: String) -> CommandOutput {
        guard let boolValue = parseBool(value) else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: on/off or true/false",
                isError: true
            )
        }

        UserDefaults.standard.set(boolValue, forKey: "simulation.autoSave")
        return CommandOutput(
            text: "AUTO_SAVE_SET: \(boolValue ? "ENABLED" : "DISABLED") | Changes \(boolValue ? "persist automatically" : "require manual save")."
        )
    }

    private func handleSetUpdateInterval(value: String) -> CommandOutput {
        guard let interval = Double(value), interval >= 100, interval <= 10000 else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: number between 100 and 10000 (milliseconds)",
                isError: true
            )
        }

        UserDefaults.standard.set(interval, forKey: "simulation.updateInterval")
        return CommandOutput(
            text: "UPDATE_INTERVAL_SET: \(Int(interval))ms | The city's heartbeat \(interval < 1000 ? "quickens" : "slows")."
        )
    }

    // MARK: - Debug Settings Handlers

    private func handleSetVerbose(value: String) -> CommandOutput {
        guard let boolValue = parseBool(value) else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: on/off or true/false",
                isError: true
            )
        }

        UserDefaults.standard.set(boolValue, forKey: "debug.verbose")
        return CommandOutput(
            text: "VERBOSE_LOGGING_SET: \(boolValue ? "ENABLED" : "DISABLED") | The system \(boolValue ? "speaks in detail" : "falls quiet")."
        )
    }

    private func handleSetShowStats(value: String) -> CommandOutput {
        guard let boolValue = parseBool(value) else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: on/off or true/false",
                isError: true
            )
        }

        UserDefaults.standard.set(boolValue, forKey: "debug.showStats")
        return CommandOutput(
            text: "SHOW_STATS_SET: \(boolValue ? "ENABLED" : "DISABLED") | Statistics \(boolValue ? "reveal themselves" : "fade from view")."
        )
    }

    private func handleSetPerformance(value: String) -> CommandOutput {
        guard let boolValue = parseBool(value) else {
            return CommandOutput(
                text: "INVALID_VALUE: '\(value)' | Expected: on/off or true/false",
                isError: true
            )
        }

        UserDefaults.standard.set(boolValue, forKey: "debug.performance")
        return CommandOutput(
            text: "PERFORMANCE_MONITOR_SET: \(boolValue ? "ENABLED" : "DISABLED") | The system's pulse \(boolValue ? "becomes visible" : "returns to shadow")."
        )
    }

    // MARK: - Setting Helpers

    private func parseBool(_ value: String) -> Bool? {
        let normalized = value.lowercased()
        switch normalized {
        case "true", "on", "yes", "1", "enabled":
            return true
        case "false", "off", "no", "0", "disabled":
            return false
        default:
            return nil
        }
    }

    // MARK: - Helpers

    private func findCity(by target: String) -> City? {
        let cities = allCities

        // Try to find by index [00]
        if target.hasPrefix("[") && target.hasSuffix("]") {
            let indexString = target.dropFirst().dropLast()
            if let index = Int(indexString), index >= 0 && index < cities.count {
                return cities[index]
            }
        }

        // Try to find by name (case-insensitive)
        return cities.first { $0.name.lowercased() == target.lowercased() }
    }

    private func findItem(in city: City, by target: String) -> Item? {
        let items = city.items

        // Try to find by index [00]
        if target.hasPrefix("[") && target.hasSuffix("]") {
            let indexString = target.dropFirst().dropLast()
            if let index = Int(indexString), index >= 0 && index < items.count {
                return items[index]
            }
        }

        // Try to find by title (case-insensitive partial match)
        return items.first { item in
            guard let title = item.title else { return false }
            return title.lowercased().contains(target.lowercased())
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes % 60, seconds % 60)
        } else {
            return String(format: "%02d:%02d", minutes, seconds % 60)
        }
    }
}
