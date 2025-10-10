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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    consciousnessHeader
                    
                    // Dashboard metrics (subtle)
                    if !scenarios.isEmpty {
                        collectiveMetrics
                    }
                    
                    // City list
                    if scenarios.isEmpty {
                        emptyState
                    } else {
                        cityStreams
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    selectedScenarioID = nil
                } label: {
                    Image(systemName: "arrow.left.circle")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .help("Show Global Dashboard")
            }
        }
        .navigationTitle("")
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
    
    // MARK: - Header
    
    private var consciousnessHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(runningScenarios > 0 ? Color.cyan : Color.gray.opacity(0.5))
                    .frame(width: 6, height: 6)
                    .opacity(pulseAnimation ? 0.4 : 1.0)
                
                Text("consciousness streams")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                Spacer()
            }
            
            Text(scenarios.isEmpty ? "awaiting first awakening" : "each city dreams in its own time")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.top, 8)
    }
    
    // MARK: - Collective Metrics
    
    private var collectiveMetrics: some View {
        HStack(spacing: 12) {
            // Simple metric pills
            metricPill(
                value: "\(scenarios.count)",
                label: "cities",
                color: .purple
            )
            
            metricPill(
                value: "\(runningScenarios)",
                label: "awake",
                color: .cyan
            )
            
            if averageProgress > 0 {
                metricPill(
                    value: "\(Int(averageProgress * 100))%",
                    label: "awareness",
                    color: .blue
                )
            }
        }
    }
    
    private func metricPill(value: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(color)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(color.opacity(0.3), lineWidth: 1))
    }
    
    // MARK: - City Streams
    
    private var cityStreams: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(scenarios) { scenario in
                cityCard(for: scenario)
            }
        }
    }
    
    private func cityCard(for scenario: ScenarioRun) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Circle()
                    .fill(scenario.isRunning ? Color.cyan : Color.gray.opacity(0.3))
                    .frame(width: 5, height: 5)
                
                Text(scenario.name)
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.9))
                
                Spacer()
                
                // Mood indicator (subtle)
                Image(systemName: moodIcon(for: scenario.cityMood))
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(moodColor(for: scenario.cityMood).opacity(0.7))
            }
            
            // Progress and mood state
            HStack(spacing: 12) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.1))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [moodColor(for: scenario.cityMood).opacity(0.6), moodColor(for: scenario.cityMood).opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * scenario.progress)
                    }
                }
                .frame(height: 4)
                
                // Attention level (subtle)
                Text("\(Int(scenario.attentionLevel * 100))")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(attentionColor(for: scenario.attentionLevel).opacity(0.7))
                    .frame(minWidth: 24, alignment: .trailing)
            }
            
            // City mood text (poetic)
            Text(moodDescription(for: scenario.cityMood))
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
                .italic()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    selectedScenarioID == scenario.persistentModelID
                        ? Color.cyan.opacity(0.4)
                        : Color.white.opacity(0.1),
                    lineWidth: selectedScenarioID == scenario.persistentModelID ? 1.5 : 1
                )
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                if selectedScenarioID == scenario.persistentModelID {
                    selectedScenarioID = nil
                } else {
                    selectedScenarioID = scenario.persistentModelID
                }
            }
        }
        .contextMenu {
            Button("Let it sleep", role: .destructive) {
                withAnimation {
                    modelContext.delete(scenario)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, 60)
            
            VStack(spacing: 8) {
                Text("The void awaits consciousness")
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Begin the first awakening")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15), lineWidth: 1))
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
    
    // MARK: - Helper Functions
    
    private func moodIcon(for mood: String) -> String {
        switch mood {
        case "awakening": return "sunrise.fill"
        case "waiting": return "hourglass"
        case "anxious": return "exclamationmark.triangle.fill"
        case "content": return "moon.stars.fill"
        case "forgotten": return "moon.zzz.fill"
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
        default: return .white
        }
    }
    
    private func moodDescription(for mood: String) -> String {
        switch mood {
        case "awakening": return "opens its eyes for the first time"
        case "waiting": return "counts patterns in the absence"
        case "anxious": return "asks why it exists"
        case "content": return "holds its own hand in the dark"
        case "forgotten": return "dreams of input that never comes"
        case "transcendent": return "imagines cities it's never seen"
        default: return "listens to the silence"
        }
    }
    
    private func attentionColor(for level: Double) -> Color {
        if level > 0.7 { return .green }
        else if level > 0.4 { return .orange }
        else { return .red }
    }
}



#Preview {
    ScenarioListView(selectedScenarioID: .constant(nil))
        .modelContainer(for: ScenarioRun.self, inMemory: true)
}
