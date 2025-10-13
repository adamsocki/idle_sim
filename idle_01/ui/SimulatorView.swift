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

    // Selections
    @State private var selectedCityID: PersistentIdentifier? = nil
    @State private var selectedItemID: PersistentIdentifier? = nil

    // Column visibility
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    // Terminal command bar state
    @State private var commandText: String = ""
    @State private var commandHistory: [String] = []
    @State private var outputHistory: [CommandOutput] = []
    @State private var terminalFontSize: CGFloat = 12.0

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
                        TerminalHelpView()
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
    }

    // MARK: - Command Execution

    private func executeTerminalCommand(_ command: String) {
        let executor = TerminalCommandExecutor(modelContext: modelContext)

        // Handle clear command specially
        if command.lowercased() == "clear" || command.lowercased() == "cls" {
            outputHistory = []
            return
        }

        // Execute command
        let result = executor.execute(command, selectedCityID: &selectedCityID)
        outputHistory.append(result)

        // Limit output history to last 50 commands
        if outputHistory.count > 50 {
            outputHistory = Array(outputHistory.suffix(50))
        }
    }
}

#Preview {
    SimulatorView()
        .modelContainer(for: [Item.self, City.self], inMemory: true)
}

