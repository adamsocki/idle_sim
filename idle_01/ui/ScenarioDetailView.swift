//
//  ScenarioDetailView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//


import SwiftUI
import SwiftData


struct ScenarioDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    let scenario: ScenarioRun?

    @State private var isStarting = false
    
    var body: some View {
        Group {
            if let s = scenario {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header(for: s)
                        
                        ProgressView(value: s.progress)
                            .animation(.easeInOut, value: s.progress)
                        
                        Divider()
                        
                        // City Consciousness Panel
                        CityConsciousnessView(scenario: s)
                        
                        Divider()
                        
                        // Awareness Events
                        if !s.awarenessEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Awareness Events")
                                    .font(.headline)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(Array(s.awarenessEvents.suffix(5).enumerated()), id: \.offset) { _, event in
                                        HStack(alignment: .top, spacing: 6) {
                                            Image(systemName: "sparkle")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                            Text(event)
                                                .font(.callout)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.purple.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                        
                        Divider()
                        
                        Text("Simulation Log").font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(s.log.suffix(20).enumerated()), id: \.offset) { _, line in
                                Text("• \(line)")
                                    .font(.callout)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Select or create a scenario to begin.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    @ViewBuilder
    private func header(for s: ScenarioRun) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(s.name).font(.largeTitle).bold()
                Text(s.createdAt, style: .date).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                Task { await start(s) }
            } label: {
                Label(s.isRunning ? "Running…" : "Start Simulation",
                      systemImage: s.isRunning ? "hourglass" : "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(s.isRunning || isStarting)
        }
    }

    private func start(_ s: ScenarioRun) async {
        guard !s.isRunning else { return }
        isStarting = true
        let engine = SimulationEngine(context: modelContext)
        await engine.run(s)
        isStarting = false
    }
}
