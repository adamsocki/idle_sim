//
//  SimulatorView.swift
//  idle_01
//
//  Created by Adam Socki on 9/29/25.
//

import SwiftUI
import SwiftData

struct SimulatorView: View {

    @Environment(\.modelContext) private var modelContext

    // Feature flag for terminal command bar
    @AppStorage("useTerminalCommandBar") private var useTerminalCommandBar: Bool = true

    // Narrative mode flag - when true, routes commands through NarrativeEngine
    @AppStorage("useNarrativeMode") private var useNarrativeMode: Bool = true

    // Auto-reset flag - when true, resets game state on app launch
    @AppStorage("autoResetOnLaunch") private var autoResetOnLaunch: Bool = true

    // Terminal settings from @AppStorage
    @AppStorage("terminal.fontSize") private var terminalFontSize: Double = 12

    // Selections
    @State private var selectedCityID: PersistentIdentifier? = nil
    @State private var selectedItemID: PersistentIdentifier? = nil

    // Column visibility
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    // Terminal command bar state
    @State private var commandText: String = ""
    @State private var commandHistory: [String] = []
    @State private var outputHistory: [CommandOutput] = []
    @State private var showSettings: Bool = false

    // Narrative engine (initialized on appear)
    @State private var narrativeEngine: NarrativeEngine?

    // Command history persistence key
    private let commandHistoryKey = "terminal.commandHistory"

    // Column visibility - persisted in SwiftData
    @Query private var userPreferences: [UserPreferences]

    // all data
    @Query private var allCities: [City]
    @Query private var allItems: [Item]
    @Query private var allGameStates: [GameState]

    // Lookup helpers
    private var selectedCity: City? {
        guard let id = selectedCityID else { return nil }
        return allCities.first { $0.persistentModelID == id }
    }
    private var selectedItem: Item? {
        guard
            let city = selectedCity,
            let itemID = selectedItemID
        else { return nil }
        return city.items.first { $0.persistentModelID == itemID }
    }

    var body: some View {
        ZStack {
            // Main 2-column split view (terminal + settings/help)
            HSplitView {
                // Left: Terminal (main workspace)
                if useTerminalCommandBar {
                    TerminalInputView(
                        commandText: $commandText,
                        terminalFontSize: $terminalFontSize,
                        commandHistory: $commandHistory,
                        outputHistory: $outputHistory,
                        selectedCityName: selectedCity?.name,
                        onExecute: { command in
                            executeTerminalCommand(command)
                        }
                    )
                } else {
                    // Fallback to original views if terminal is disabled
                    Group {
                        if let city = selectedCity {
                            CityView(city: city, selectedItemID: $selectedItemID)
                        } else {
                            GlobalDashboardView()
                        }
                    }
                }

                // Right: Settings/Help panel
                ZStack(alignment: .topTrailing) {
                    // Show either settings or help
                    if showSettings {
                        TerminalSettingsView()
                    } else {
                        TerminalHelpView(gameState: allGameStates.first)
                    }

                    // Toggle button in top-right corner
                    Button(action: { showSettings.toggle() }) {
                        HStack(spacing: 4) {
                            Text("[")
                                .foregroundStyle(Color.green.opacity(0.6))

                            Image(systemName: showSettings ? "book.fill" : "gearshape.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.green.opacity(0.9))

                            Text("]")
                                .foregroundStyle(Color.green.opacity(0.6))
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)
                    .help(showSettings ? "Show Help" : "Show Settings")
                    .padding(16)
                }
                .frame(minWidth: 250, idealWidth: 300, maxWidth: 400)
            }

            // Debug stats overlay
            DebugStatsOverlay(cities: allCities)
                .allowsHitTesting(false)
        }
        .onAppear {
            loadCommandHistory()
            initializeNarrativeEngine()
        }
    }

    // MARK: - Narrative Engine Initialization

    private func initializeNarrativeEngine() {
        guard let gameState = allGameStates.first else {
            print("⚠️ No GameState found")
            return
        }

        narrativeEngine = NarrativeEngine(modelContext: modelContext, gameState: gameState)

        // Reset game if auto-reset is enabled
        if autoResetOnLaunch {
            narrativeEngine?.resetGame()
            print("✅ NarrativeEngine initialized - Game reset to Act 1")
        } else {
            print("✅ NarrativeEngine initialized - Act \(gameState.currentAct)")
        }

        // Add welcome message to output
        let welcome = """
        === CONSCIOUSNESS INITIALIZED ===

        Type HELP for available commands
        Type STATUS to view current state

        Act I: "The First Breaths"
        A city begins to remember...
        """

        outputHistory.append(CommandOutput(text: welcome, isError: false, isDialogue: true))
    }

    // MARK: - Command Execution

    private func executeTerminalCommand(_ command: String) {
        // Handle clear command specially
        if command.lowercased() == "clear" || command.lowercased() == "cls" {
            outputHistory = []
            return
        }

        // First, echo the command that was entered
        let commandEcho = CommandOutput(text: "> \(command)", isError: false)
        outputHistory.append(commandEcho)

        // Check if narrative mode is enabled and we have a narrative engine
        if useNarrativeMode, let engine = narrativeEngine {
            // Try to parse as narrative command
            let narrativeCmd = NarrativeCommand.parse(command)

            // If it's a recognized narrative command, route through narrative engine
            if !isUnknownCommand(narrativeCmd) {
                Task { @MainActor in
                    let result = await engine.processCommand(command)

                    // Convert to CommandOutput
                    let output = CommandOutput(
                        text: result.text,
                        isError: result.isError,
                        isDialogue: result.isDialogue
                    )

                    outputHistory.append(output)

                    // If this was a reset command, clear output history and show welcome message
                    if case .reset = narrativeCmd {
                        outputHistory = []
                        let welcome = """
                        === CONSCIOUSNESS INITIALIZED ===

                        Type HELP for available commands
                        Type STATUS to view current state

                        Act I: "The First Breaths"
                        A city begins to remember...
                        """
                        outputHistory.append(CommandOutput(text: welcome, isError: false, isDialogue: true))
                    }

                    // Limit output history to last 100 commands
                    if outputHistory.count > 100 {
                        outputHistory = Array(outputHistory.suffix(100))
                    }

                    saveCommandHistory()
                }
                return
            }
        }

        // Unknown command - show error message
        let errorOutput = CommandOutput(
            text: "Unknown command: '\(command)'\nType HELP for available commands",
            isError: true
        )
        outputHistory.append(errorOutput)
        saveCommandHistory()
    }

    private func isUnknownCommand(_ command: NarrativeCommand) -> Bool {
        if case .unknown = command {
            return true
        }
        return false
    }

    // MARK: - Command History Persistence

    private func loadCommandHistory() {
        if let savedHistory = UserDefaults.standard.stringArray(forKey: commandHistoryKey) {
            // Limit to last 100 commands
            commandHistory = Array(savedHistory.suffix(100))
        }
    }

    private func saveCommandHistory() {
        // Save last 100 commands
        let historyToSave = Array(commandHistory.suffix(100))
        UserDefaults.standard.set(historyToSave, forKey: commandHistoryKey)
    }
}

#Preview {
    SimulatorView()
        .modelContainer(for: [Item.self, City.self], inMemory: true)
}

