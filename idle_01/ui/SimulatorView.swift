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

    // Selections
    @State private var selectedScenarioID: PersistentIdentifier? = nil
    @State private var selectedItemID: PersistentIdentifier? = nil

    // Column visibility - persisted in SwiftData
    @Query private var userPreferences: [UserPreferences]

    // all data
    @Query private var allScenarios: [ScenarioRun]
    @Query private var allItems: [Item]
       
    // Lookup helpers
    private var selectedScenario: ScenarioRun? {
        guard let id = selectedScenarioID else { return nil }
        return allScenarios.first { $0.persistentModelID == id }
    }
    private var selectedItem: Item? {
        guard
            let scenario = selectedScenario,
            let itemID = selectedItemID
        else { return nil }
        return scenario.items.first { $0.persistentModelID == itemID }
    }

    var body: some View {
    NavigationSplitView() {
            ScenarioListView(selectedScenarioID: $selectedScenarioID)
        } content: {
            Group {
                if let scenario = selectedScenario {
                    SimulationStageView(scenario: scenario, selectedItemID: $selectedItemID)
                } else {
                    GlobalDashboardView()
                }
            }
            
            
        } detail: {
            Group {
                if let item = selectedItem {
                    DetailView(item: item)
                } else if let scenario = selectedScenario {
                    ScenarioDetailView(scenario: scenario)
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "sidebar.right")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundStyle(.secondary)

                        Text("No Selection")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        Text("Select a scenario or item to view details")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 350)
        }
    }
}

#Preview {
    SimulatorView()
        .modelContainer(for: [Item.self, ScenarioRun.self], inMemory: true)
}

