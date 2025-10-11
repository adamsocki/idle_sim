//
//  DashboardView.swift
//  idle_01
//
//  Created by AI Assistant on 9/29/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var items: [Item]
    @Query private var cities: [City]

    private var latestItemDate: Date? {
        items.map { $0.timestamp }.sorted(by: >).first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()

                // --- Existing Items Summary ---
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "tray.full")
//                                .padding(.leading, )
                            Text("Total Items")
                                .font(.headline)
                            Spacer()
                            Text("\(items.count)")
                                .font(.title2)
                                .monospacedDigit()
                                .padding(.trailing, 5)
                        }

                        Divider()

                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)
                            Text("Most Recent")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(latestItemDate ?? .distantPast, format: Date.FormatStyle(date: .numeric, time: .standard))
                                .font(.body)
                                .foregroundStyle(latestItemDate == nil ? .tertiary : .primary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // --- Cities Section --- //
                HStack {
                    Text("Cities")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button {
                        createCity()
                    } label: {
                        Label("New City", systemImage: "plus")
                    }
                }

                if cities.isEmpty {
                    ContentUnavailableView(
                        "No Cities Yet",
                        systemImage: "externaldrive",
                        description: Text("Tap \"New City\" to create one.")
                    )
                    .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .background(.background)
        .navigationTitle("Dashboard")
    }
    
    // MARK: - Create City
    private func createCity() {
        print("createCity()")
    }
}

// MARK: - City Card + city-scoped timers
//private struct createScenario

#Preview {
    DashboardView()
        .modelContainer(for: Item.self, inMemory: true)
}
