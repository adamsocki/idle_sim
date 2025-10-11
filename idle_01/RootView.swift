//
//  RootView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//



import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        TabView {
            // Tab 1: Simulations (your 3-column split with integrated dashboard)
            SimulatorView()
                .tabItem {
                    Label("Simulations", systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [City.self, Item.self], inMemory: true)
}
