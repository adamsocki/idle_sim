//
//  CityListView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//

import SwiftUI
import SwiftData

struct CityListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \City.createdAt, order: .reverse)
    private var cities: [City]
    
    @Binding var selectedCityID: PersistentIdentifier?
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Deep atmospheric background
            atmosphericBackground
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    ConsciousnessHeaderView(
                        cityCount: cities.count,
                        runningCities: runningCities,
                        pulseAnimation: $pulseAnimation
                    )

                    // New City Button
                    newCityButton

                    // Dashboard metrics (subtle)
                    if !cities.isEmpty {
                        CollectiveMetricsView(
                            totalCities: cities.count,
                            awakeCities: runningCities,
                            averageProgress: averageProgress
                        )
                    }
                    
                    // City list
                    if cities.isEmpty {
                        EmptyStateView()
                    } else {
                        cityList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                backButton
            }
        }
        .navigationTitle("")
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
    
    // MARK: - Subviews
    
    private var atmosphericBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.08, blue: 0.15),
                Color(red: 0.08, green: 0.05, blue: 0.12),
                Color(red: 0.02, green: 0.05, blue: 0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var cityList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(cities) { city in
                CityCardView(
                    city: city,
                    isSelected: selectedCityID == city.persistentModelID,
                    onTap: {
                        if selectedCityID == city.persistentModelID {
                            selectedCityID = nil
                        } else {
                            selectedCityID = city.persistentModelID
                        }
                    }
                )
            }
        }
    }
    
    private var newCityButton: some View {
        LiquidButton("awaken", systemImage: "eye.fill", style: .standard, action: createNewCity)
    }
    
    private var backButton: some View {
        Button {
            selectedCityID = nil
        } label: {
            Image(systemName: "arrow.left.circle")
                .foregroundStyle(.white.opacity(0.7))
        }
        .help("Show Global Dashboard")
    }
    
    // MARK: - Actions
    
    private func createNewCity() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            let newCity = City(name: "unnamed city", parameters: ["growthRate": 0.02])
            modelContext.insert(newCity)
            selectedCityID = newCity.persistentModelID
        }
    }
    
    // MARK: - Computed Properties
    
    private var runningCities: Int {
        cities.filter { $0.isRunning }.count
    }
    
    private var averageProgress: Double {
        guard !cities.isEmpty else { return 0 }
        return cities.reduce(0.0) { $0 + $1.progress } / Double(cities.count)
    }
}

#Preview {
    CityListView(selectedCityID: .constant(nil))
        .modelContainer(for: City.self, inMemory: true)
}
