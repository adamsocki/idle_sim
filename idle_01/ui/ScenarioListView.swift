//
//  ScenarioListView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//

import SwiftUI
import SwiftData

struct ScenarioListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScenarioRun.createdAt, order: .reverse)
    private var scenarios: [ScenarioRun]
    
    @Binding var selectedScenarioID: PersistentIdentifier?
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Deep atmospheric background
            atmosphericBackground
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    ConsciousnessHeaderView(
                        scenarioCount: scenarios.count,
                        runningScenarios: runningScenarios,
                        pulseAnimation: $pulseAnimation
                    )
                    
                    // Dashboard metrics (subtle)
                    if !scenarios.isEmpty {
                        CollectiveMetricsView(
                            totalCities: scenarios.count,
                            awakeCities: runningScenarios,
                            averageProgress: averageProgress
                        )
                    }
                    
                    // City list
                    if scenarios.isEmpty {
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
            ToolbarItem(placement: .primaryAction) {
                newCityButton
            }
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
            ForEach(scenarios) { scenario in
                CityCardView(
                    scenario: scenario,
                    isSelected: selectedScenarioID == scenario.persistentModelID,
                    onTap: {
                        if selectedScenarioID == scenario.persistentModelID {
                            selectedScenarioID = nil
                        } else {
                            selectedScenarioID = scenario.persistentModelID
                        }
                    }
                )
            }
        }
    }
    
    private var newCityButton: some View {
        Button {
            createNewScenario()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "eye.fill")
                Text("awaken")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
        }
        .foregroundStyle(.white)
    }
    
    private var backButton: some View {
        Button {
            selectedScenarioID = nil
        } label: {
            Image(systemName: "arrow.left.circle")
                .foregroundStyle(.white.opacity(0.7))
        }
        .help("Show Global Dashboard")
    }
    
    // MARK: - Actions
    
    private func createNewScenario() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            let newScenario = ScenarioRun(name: "unnamed city", parameters: ["growthRate": 0.02])
            modelContext.insert(newScenario)
            selectedScenarioID = newScenario.persistentModelID
        }
    }
    
    // MARK: - Computed Properties
    
    private var runningScenarios: Int {
        scenarios.filter { $0.isRunning }.count
    }
    
    private var averageProgress: Double {
        guard !scenarios.isEmpty else { return 0 }
        return scenarios.reduce(0.0) { $0 + $1.progress } / Double(scenarios.count)
    }
}

#Preview {
    ScenarioListView(selectedScenarioID: .constant(nil))
        .modelContainer(for: ScenarioRun.self, inMemory: true)
}
