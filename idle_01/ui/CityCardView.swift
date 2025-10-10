//
//  CityCardView.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI
import SwiftData

struct CityCardView: View {
    @Environment(\.modelContext) private var modelContext
    let scenario: ScenarioRun
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            cityHeader
            
            // Progress and mood state
            progressBar
            
            // City mood text (poetic)
            moodText
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isSelected ? Color.cyan.opacity(0.4) : Color.white.opacity(0.1),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
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
    
    // MARK: - Subviews
    
    private var cityHeader: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(scenario.isRunning ? Color.cyan : Color.gray.opacity(0.3))
                .frame(width: 5, height: 5)
            
            Text(scenario.name)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.9))
            
            Spacer()
            
            // Mood indicator (subtle)
            Image(systemName: CityMoodHelper.icon(for: scenario.cityMood))
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(CityMoodHelper.color(for: scenario.cityMood).opacity(0.7))
        }
    }
    
    private var progressBar: some View {
        HStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.1))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    CityMoodHelper.color(for: scenario.cityMood).opacity(0.6),
                                    CityMoodHelper.color(for: scenario.cityMood).opacity(0.3)
                                ],
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
                .foregroundStyle(CityMoodHelper.attentionColor(for: scenario.attentionLevel).opacity(0.7))
                .frame(minWidth: 24, alignment: .trailing)
        }
    }
    
    private var moodText: some View {
        Text(CityMoodHelper.description(for: scenario.cityMood))
            .font(.system(size: 11, weight: .regular, design: .monospaced))
            .foregroundStyle(.white.opacity(0.4))
            .italic()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CityCardView(
            scenario: ScenarioRun(name: "Test City", parameters: ["growthRate": 0.02]),
            isSelected: false,
            onTap: {}
        )
        .padding()
        .modelContainer(for: ScenarioRun.self, inMemory: true)
    }
}
