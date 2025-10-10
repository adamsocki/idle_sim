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
        ScrollView {
            VStack(alignment: .leading, spacing: 20)  {
                header
                Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                    GridRow {
                        statCard(title: "Scenarios", value: "\(totalScenarios)", systemImage: "folder")
                        statCard(title: "Running", value: "\(runningScenarios)", systemImage: "hourglass")
                    }
                    GridRow {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Average Progress").font(.headline)
                            ProgressView(value: averageProgress)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                Text("Global Dashboard")
                    .font(.largeTitle)
                    .padding()
                GroupBox("Active Scenarios") {
                    if scenarios.isEmpty {
                        Text("No scenarios yet. Create one in the Simulations tab.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        
    }
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Global Dashboard")
                    .font(.largeTitle).bold()
                Text("Overview across all scenarios and tasks.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
              
            Button {
                let s = ScenarioRun(name: "spawn city", parameters: ["growthRate": 0.02])
                modelContext.insert(s)
            } label: {
                HStack{
                    
                    Label("new concenious", systemImage: "plus")
                    .font(.title2)
                }
            }
            .buttonStyle(.glass)
//            .foregroundStyle(.black)
        }
    }
    private func statCard(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage).font(.headline)
            Text(value).font(.title2).bold().monospacedDigit()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.quaternary))
    }
    
}


#Preview {
    GlobalDashboardView()
        .modelContainer(for: [ScenarioRun.self], inMemory: true)
}
