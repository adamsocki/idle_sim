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
    @State private var selectedCityID: PersistentIdentifier? = nil
    @State private var selectedItemID: PersistentIdentifier? = nil

    // Column visibility
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

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
        NavigationSplitView(columnVisibility: $columnVisibility) {
            CityListView(selectedCityID: $selectedCityID)
        } content: {
            Group {
                if let city = selectedCity {
                    CityView(city: city, selectedItemID: $selectedItemID)
                } else {
                    GlobalDashboardView()
                }
            }
        } detail: {
            Group {
                if let item = selectedItem {
                    DetailView(item: item)
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
            .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 350)
        }
    }
}

#Preview {
    SimulatorView()
        .modelContainer(for: [Item.self, City.self], inMemory: true)
}

