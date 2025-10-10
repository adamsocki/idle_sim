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
    
    var body: some View {
        List {
            // Dashboard Header Section
            Section {
                dashboardHeader
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            
            // Scenarios Section
            Section("Cities") {
                ForEach(scenarios) { s in
                HStack(spacing: 12) {
                    // Mood indicator
                    Image(systemName: moodIcon(for: s.cityMood))
                        .foregroundColor(moodColor(for: s.cityMood))
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(s.name).font(.headline)
                            if s.isRunning { 
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(.secondary) 
                            }
                        }
                        
                        HStack(spacing: 8) {
                            // Progress bar
                            ProgressView(value: s.progress)
                                .frame(maxWidth: 120)
                            
                            // City mood text
                            Text(s.cityMood.capitalized)
                                .font(.caption2)
                                .foregroundColor(moodColor(for: s.cityMood))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(moodColor(for: s.cityMood).opacity(0.15))
                                .cornerRadius(3)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(s.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        // Attention indicator
                        HStack(spacing: 2) {
                            Image(systemName: "eye.fill")
                                .font(.caption2)
                            Text("\(Int(s.attentionLevel * 100))%")
                                .font(.caption2)
                        }
                        .foregroundColor(attentionColor(for: s.attentionLevel))
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(
                    (selectedScenarioID == s.persistentModelID)
                    ? Color.accentColor.opacity(0.08)
                    : Color.clear
                )
                .onTapGesture {
                    if selectedScenarioID == s.persistentModelID {
                        selectedScenarioID = nil // Deselect if tapping the selected row
                    } else {
                        selectedScenarioID = s.persistentModelID
                    }
                }
                .contextMenu {
                    Button("Delete", role: .destructive) { modelContext.delete(s) }
                }
            }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    createNewScenario()
                } label: {
                    Label("New City", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    selectedScenarioID = nil
                } label: {
                    Label("Clear Selection", systemImage: "xmark.circle")
                }
                .help("Show Global Dashboard")
            }
        }
        .navigationTitle("Cities")
    }
    
    // MARK: - Actions
    
    private func createNewScenario() {
        let newScenario = ScenarioRun(name: "New City", parameters: ["growthRate": 0.02])
        modelContext.insert(newScenario)
        // Auto-select the new scenario
        selectedScenarioID = newScenario.persistentModelID
    }
    
    // MARK: - Dashboard Header
    
    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Metrics Grid
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow {
                    metricCard(
                        title: "Cities", 
                        value: "\(scenarios.count)", 
                        icon: "building.2.fill",
                        color: .blue
                    )
                    metricCard(
                        title: "Awakening", 
                        value: "\(runningScenarios)", 
                        icon: "sparkles",
                        color: .green
                    )
                }
                GridRow {
                    metricCard(
                        title: "Completed", 
                        value: "\(completedScenarios)", 
                        icon: "checkmark.circle.fill",
                        color: .purple
                    )
                    metricCard(
                        title: "Progress", 
                        value: String(format: "%.0f%%", averageProgress * 100), 
                        icon: "chart.line.uptrend.xyaxis",
                        color: .orange
                    )
                }
            }
            
            // Overall Progress Bar
            if !scenarios.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Collective Consciousness")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.1f%%", averageProgress * 100))
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: averageProgress)
                        .tint(.blue)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func metricCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.callout)
                    .bold()
                    .monospacedDigit()
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Computed Properties
    
    private var runningScenarios: Int {
        scenarios.filter { $0.isRunning }.count
    }
    
    private var completedScenarios: Int {
        scenarios.filter { $0.progress >= 1.0 }.count
    }
    
    private var averageProgress: Double {
        guard !scenarios.isEmpty else { return 0 }
        return scenarios.reduce(0.0) { $0 + $1.progress } / Double(scenarios.count)
    }
    
    // MARK: - Helper Functions
    
    private func moodIcon(for mood: String) -> String {
        switch mood {
        case "awakening": return "sunrise.fill"
        case "waiting": return "hourglass"
        case "anxious": return "exclamationmark.triangle.fill"
        case "content": return "checkmark.circle.fill"
        case "forgotten": return "moon.stars.fill"
        case "transcendent": return "sparkles"
        default: return "circle.fill"
        }
    }
    
    private func moodColor(for mood: String) -> Color {
        switch mood {
        case "awakening": return .orange
        case "waiting": return .blue
        case "anxious": return .red
        case "content": return .green
        case "forgotten": return .gray
        case "transcendent": return .purple
        default: return .secondary
        }
    }
    
    private func attentionColor(for level: Double) -> Color {
        if level > 0.7 { return .green }
        else if level > 0.4 { return .orange }
        else { return .red }
    }
}
