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
        SimulatorView()
    }
}

#Preview {
    RootView()
        .modelContainer(for: [City.self, Item.self], inMemory: true)
}
