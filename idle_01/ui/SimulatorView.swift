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
        NavigationSplitView {
            ScenarioListView(selectedScenarioID: $selectedScenarioID)
        } content: {
            if let scenario = selectedScenario {
                SimulationStageView(scenario: scenario, selectedItemID: $selectedItemID)
            } else {
                GlobalDashboardView()
            }
        } detail: {
            // Contextual detail panel
            if let item = selectedItem {
                DetailView(item: item)
            } else if let scenario = selectedScenario {
                ScenarioDetailView(scenario: scenario)
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    SimulatorView()
        .modelContainer(for: Item.self, inMemory: true)
}
