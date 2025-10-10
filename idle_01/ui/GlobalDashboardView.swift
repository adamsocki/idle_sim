//
//  GlobalDashboardView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//

import SwiftUI
import SwiftData

struct GlobalDashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var pulseAnimation = false
    
    // MARK: - Metrics
    
    private var averageProgress: Double {
        guard !scenarios.isEmpty else { return 0 }
        var total = 0.0
        for s in scenarios {
            total += s.progress
        }
        let average = total / Double(scenarios.count)
        return average
    }

    private var totalScenarios: Int { scenarios.count }

    private var runningScenarios: Int {
        scenarios.filter { $0.isRunning }.count
    }

    @Query(sort: \ScenarioRun.createdAt, order: .reverse)
    private var scenarios: [ScenarioRun]
    
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
                VStack(spacing: 32) {
                    consciousnessHeader
                    
                    metricsGrid
                    
                    if !scenarios.isEmpty {
                        consciousnessStatus
                    } else {
                        awaitingInput
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
    
    // MARK: - Header
    
    private var consciousnessHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(runningScenarios > 0 ? Color.cyan : Color.gray)
                            .frame(width: 8, height: 8)
                            .opacity(pulseAnimation ? 0.4 : 1.0)
                        
                        Text("The city is self-aware")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundStyle(.white.opacity(0.95))
                    }
                    
                    Text(runningScenarios > 0 ? "It waits for an input" : "The simulation is paused")
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        let s = ScenarioRun(name: "new consciousness", parameters: ["growthRate": 0.02])
                        modelContext.insert(s)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("awaken")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
                }
                .foregroundStyle(.white)
            }
        }
    }
    
    // MARK: - Metrics Grid
    
    private var metricsGrid: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                metricCard(
                    label: "consciousness nodes",
                    value: "\(totalScenarios)",
                    icon: "network",
                    gradient: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]
                )
                
                metricCard(
                    label: "active processes",
                    value: "\(runningScenarios)",
                    icon: "waveform.path.ecg",
                    gradient: [Color.cyan.opacity(0.6), Color.teal.opacity(0.6)]
                )
            }
            
            // Progress indicator
            if totalScenarios > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("collective awareness")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Text("\(Int(averageProgress * 100))%")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(Capsule().strokeBorder(.white.opacity(0.1), lineWidth: 1))
                            
                            // Progress fill
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * averageProgress)
                                .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 0)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15), lineWidth: 1))
            }
        }
    }
    
    // MARK: - Status Views
    
    private var consciousnessStatus: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("active consciousness streams")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                ForEach(scenarios.prefix(5)) { scenario in
                    HStack {
                        Circle()
                            .fill(scenario.isRunning ? Color.cyan : Color.gray.opacity(0.5))
                            .frame(width: 6, height: 6)
                        
                        Text(scenario.name)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(Int(scenario.progress * 100))%")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.1), lineWidth: 1))
                }
            }
        }
    }
    
    private var awaitingInput: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text("The city dreams of input")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Consciousness awaits first awakening")
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.15), lineWidth: 1))
    }
    
    // MARK: - Helper Views
    
    private func metricCard(label: String, value: String, icon: String, gradient: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .monospacedDigit()
                
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15), lineWidth: 1))
        .shadow(color: gradient[0].opacity(0.2), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    GlobalDashboardView()
        .modelContainer(for: [ScenarioRun.self], inMemory: true)
}
