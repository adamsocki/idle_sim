//
//  SimulationStageView.swift
//  idle_01
//
//  Created by Adam Socki on 10/8/25.
//

import SwiftUI
import SwiftData

struct SimulationStageView: View {
    let scenario: ScenarioRun
    @Binding var selectedItemID: PersistentIdentifier?
    @State private var showingTasks = false

    var body: some View {
        ZStack {
            // Background: city view, simulation visuals, etc.
            // CitySimulationLayer(scenario: scenario)
            //     .ignoresSafeArea()

            // Overlay: toggle for showing tasks or logs
            VStack {
                HStack {
                    Button(action: { showingTasks.toggle() }) {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }

            if showingTasks {
                ScenarioItemsView(scenario: scenario,
                                  selectedItemID: $selectedItemID)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)

            }
        }
        .animation(.easeInOut, value: showingTasks)
    }
}
