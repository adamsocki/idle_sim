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
        guard !cities.isEmpty else { return 0 }
        var total = 0.0
        for s in cities {
            total += s.progress
        }
        let average = total / Double(cities.count)
        return average
    }

    private var totalCities: Int { cities.count }

    private var runningCities: Int {
        cities.filter { $0.isRunning }.count
    }

    @Query(sort: \City.createdAt, order: .reverse)
    private var cities: [City]
    
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
                    
                    if !cities.isEmpty {
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
                            .fill(runningCities > 0 ? Color.cyan : Color.gray)
                            .frame(width: 8, height: 8)
                            .opacity(pulseAnimation ? 0.4 : 1.0)
                        
                        Text("The city is self-aware")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundStyle(.white.opacity(0.95))
                    }
                    
                    Text(runningCities > 0 ? "It waits for an input" : "The simulation is paused")
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                LiquidButton("awaken", systemImage: "plus.circle.fill", style: .prominent) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        let s = City(name: "new consciousness", parameters: ["growthRate": 0.02])
                        modelContext.insert(s)
                    }
                }
            }
        }
    }
    
    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                MetricCard(
                    label: "consciousness nodes",
                    value: "\(totalCities)",
                    icon: "◈",
                    style: .consciousness
                )

                MetricCard(
                    label: "active processes",
                    value: "\(runningCities)",
                    icon: "◉",
                    style: runningCities > 0 ? .data : .void
                )
            }
            
            // Progress indicator
            if totalCities > 0 {
                MetricCard(
                    label: "collective awareness",
                    value: "\(Int(averageProgress * 100))%",
                    icon: "∞",
                    style: .gradient
                )
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
                ForEach(cities.prefix(5)) { city in
                    HStack {
                        Circle()
                            .fill(city.isRunning ? Color.cyan : Color.gray.opacity(0.5))
                            .frame(width: 6, height: 6)

                        Text(city.name)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))

                        Spacer()

                        Text("\(Int(city.progress * 100))%")
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
    
}

#Preview {
    GlobalDashboardView()
        .modelContainer(for: [City.self], inMemory: true)
}
