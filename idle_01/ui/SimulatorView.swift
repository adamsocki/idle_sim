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

    // Command history persistence key
    private let commandHistoryKey = "terminal.commandHistory"

    // Column visibility - persisted in SwiftData
    @Query private var userPreferences: [UserPreferences]

    // all data
    @Query private var allCities: [City]
    @Query private var allItems: [Item]

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
            // Main 3-column split view
            NavigationSplitView(columnVisibility: $columnVisibility) {
                // Left column: City List
                CityListView(selectedCityID: $selectedCityID)
            } content: {
                // Middle column: Terminal (main workspace)
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
            } detail: {
            Group {
                if let item = selectedItem {
                    DetailView(item: item)
                } else {
                    // Terminal help/context when nothing selected
                    if useTerminalCommandBar {
                        ZStack(alignment: .topTrailing) {
                            // Show either settings or help
                            if showSettings {
                                TerminalSettingsView()
                            } else {
                                TerminalHelpView()
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
                    } else {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "sidebar.right")
                                .font(.system(size: 48, weight: .ultraLight))
                                .foregroundStyle(.secondary)

                            Text("No Selection")
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            Text("Select a thought to view details")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 400)
            }
            // Hidden toggle for feature flag (Cmd+T)
            .background(
                Button("") {
                    useTerminalCommandBar.toggle()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
                .hidden()
            )

            // Debug stats overlay
            DebugStatsOverlay(cities: allCities)
                .allowsHitTesting(false)
        }
        .onAppear {
            loadCommandHistory()
        }
    }

    // MARK: - Command Execution

    private func executeTerminalCommand(_ command: String) {
        let executor = TerminalCommandExecutor(modelContext: modelContext)

        // Handle clear command specially
        if command.lowercased() == "clear" || command.lowercased() == "cls" {
            outputHistory = []
            return
        }

        // First, echo the command that was entered
        let commandEcho = CommandOutput(text: "> \(command)", isError: false)
        outputHistory.append(commandEcho)

        // Check if this is a weave command (needs async handling)
        let components = command.split(separator: " ").map { String($0) }
        if let firstWord = components.first?.lowercased(),
           (firstWord == "weave" || firstWord == "thread") && components.count > 1 {
            let threadType = components[1]

            // Execute async and append results
            Task { @MainActor in
                let results = await executor.executeWeaveThreadAsync(
                    type: threadType,
                    selectedCityID: selectedCityID
                )

                for result in results {
                    outputHistory.append(result)
                }

                // Limit output history to last 50 commands
                if outputHistory.count > 50 {
                    outputHistory = Array(outputHistory.suffix(50))
                }

                saveCommandHistory()
            }
        } else {
            // Execute command synchronously and append result
            let result = executor.execute(command, selectedCityID: &selectedCityID)
            outputHistory.append(result)

            // Limit output history to last 50 commands
            if outputHistory.count > 50 {
                outputHistory = Array(outputHistory.suffix(50))
            }

            // Save command history
            saveCommandHistory()
        }
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

